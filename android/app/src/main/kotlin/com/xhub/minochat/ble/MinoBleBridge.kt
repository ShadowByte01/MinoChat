package com.xhub.minochat.ble

import android.annotation.SuppressLint
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothGatt
import android.bluetooth.BluetoothGattCharacteristic
import android.bluetooth.BluetoothGattServer
import android.bluetooth.BluetoothGattServerCallback
import android.bluetooth.BluetoothGattService
import android.bluetooth.BluetoothManager
import android.bluetooth.BluetoothProfile
import android.bluetooth.le.AdvertiseCallback
import android.bluetooth.le.AdvertiseData
import android.bluetooth.le.AdvertiseSettings
import android.bluetooth.le.ScanCallback
import android.bluetooth.le.ScanResult
import android.bluetooth.le.ScanSettings
import android.content.Context
import android.os.ParcelUuid
import java.util.UUID

/**
 * Minimal BLE GATT bridge for offline Mino Chat.
 *
 * Two-way text frames + small (< 20 KB) file chunks over a single characteristic.
 * Heavily inspired by the BluetoothLeChat reference implementation, simplified.
 *
 * Protocol (UTF-8 JSON per write):
 *   {"t":"msg","id":"uuid","from":"name","text":"hi","ts":1234567890}
 *   {"t":"file","id":"uuid","name":"a.pdf","mime":"application/pdf","size":12345,"chunk":0,"total":3,"data":"<base64>"}
 *
 * Throughput: ~3-5 KB/s. Good for messages + small files; bigger files
 * should route through Nearby Connections (Wi-Fi Direct) which is wired
 * up on the Flutter side via the `nearby_connections` plugin.
 */
class MinoBleBridge(private val ctx: Context) {

    companion object {
        // Random-but-fixed UUIDs for the Mino Chat GATT service + characteristics.
        val SERVICE_UUID: UUID = UUID.fromString("8c1f3a40-4d2b-4e7a-9b3f-4f1a6c5b9a01")
        val CHAR_TX_UUID: UUID  = UUID.fromString("8c1f3a41-4d2b-4e7a-9b3f-4f1a6c5b9a01") // phone → peripheral writes here
        val CHAR_RX_UUID: UUID  = UUID.fromString("8c1f3a42-4d2b-4e7a-9b3f-4f1a6c5b9a01") // peripheral notifies here

        const val MAX_MTU = 517
    }

    private val bm: BluetoothManager? =
        ctx.getSystemService(Context.BLUETOOTH_SERVICE) as? BluetoothManager
    private val adapter: BluetoothAdapter? = bm?.adapter

    private var gattServer: BluetoothGattServer? = null
    private var gattClient: BluetoothGatt? = null
    private var connectedDevice: BluetoothDevice? = null
    private var rxCharacteristic: BluetoothGattCharacteristic? = null

    var onFrame: ((String) -> Unit)? = null

    // ---------- Advertise + GATT server (so others can find us) ----------

    @SuppressLint("MissingPermission")
    fun startPeripheral(deviceName: String) {
        if (adapter == null || !adapter.isEnabled) return
        bm?.adapter?.name = deviceName.take(20)

        gattServer = bm?.openGattServer(ctx, serverCallback)?.apply {
            val service = BluetoothGattService(SERVICE_UUID, BluetoothGattService.SERVICE_TYPE_PRIMARY)

            val tx = BluetoothGattCharacteristic(
                CHAR_TX_UUID,
                BluetoothGattCharacteristic.PROPERTY_WRITE or BluetoothGattCharacteristic.PROPERTY_WRITE_NO_RESPONSE,
                BluetoothGattCharacteristic.PERMISSION_WRITE
            )
            val rx = BluetoothGattCharacteristic(
                CHAR_RX_UUID,
                BluetoothGattCharacteristic.PROPERTY_NOTIFY or BluetoothGattCharacteristic.PROPERTY_READ,
                BluetoothGattCharacteristic.PERMISSION_READ
            )
            rxCharacteristic = rx
            service.addCharacteristic(tx)
            service.addCharacteristic(rx)
            addService(service)
        }

        val advertiser = adapter?.bluetoothLeAdvertiser ?: return
        val settings = AdvertiseSettings.Builder()
            .setAdvertiseMode(AdvertiseSettings.ADVERTISE_MODE_LOW_LATENCY)
            .setConnectable(true)
            .setTimeout(0)
            .build()
        val data = AdvertiseData.Builder()
            .setIncludeDeviceName(true)
            .addServiceUuid(ParcelUuid(SERVICE_UUID))
            .build()
        advertiser.startAdvertising(settings, data, advertiseCallback)
    }

    private val advertiseCallback = object : AdvertiseCallback() {
        override fun onStartSuccess(settingsInEffect: AdvertiseSettings?) {}
        override fun onStartFailure(errorCode: Int) {}
    }

    private val serverCallback = object : BluetoothGattServerCallback() {
        @SuppressLint("MissingPermission")
        override fun onConnectionStateChange(device: BluetoothDevice, status: Int, newState: Int) {
            if (newState == BluetoothProfile.STATE_CONNECTED) {
                connectedDevice = device
                gattServer?.connect(device, true)
            } else if (newState == BluetoothProfile.STATE_DISCONNECTED) {
                connectedDevice = null
                gattServer?.cancelConnection(device)
            }
        }

        override fun onCharacteristicWriteRequest(
            device: BluetoothDevice,
            requestId: Int,
            characteristic: BluetoothGattCharacteristic,
            preparedWrite: Boolean,
            responseNeeded: Boolean,
            offset: Int,
            value: ByteArray
        ) {
            if (characteristic.uuid == CHAR_TX_UUID) {
                val text = String(value, Charsets.UTF_8)
                onFrame?.invoke(text)
            }
            if (responseNeeded) {
                gattServer?.sendResponse(device, requestId, BluetoothGatt.GATT_SUCCESS, 0, value)
            }
        }
    }

    // ---------- Scan + connect as central ----------

    @SuppressLint("MissingPermission")
    fun startScan(onFound: (BluetoothDevice) -> Unit) {
        val scanner = adapter?.bluetoothLeScanner ?: return
        val settings = ScanSettings.Builder()
            .setScanMode(ScanSettings.SCAN_MODE_LOW_LATENCY)
            .build()
        scanner.startScan(null, settings, object : ScanCallback() {
            override fun onScanResult(callbackType: Int, result: ScanResult) {
                val d = result.device ?: return
                val name = if (Build.VERSION.SDK_INT >= 31) result.scanRecord?.deviceName
                            else @SuppressLint("MissingPermission") d.name
                if (!name.isNullOrBlank()) onFound(d)
            }
        })
    }

    @SuppressLint("MissingPermission")
    fun connectCentral(device: BluetoothDevice) {
        gattClient = device.connectGatt(ctx, false, object : android.bluetooth.BluetoothGattCallback() {
            @SuppressLint("MissingPermission")
            override fun onConnectionStateChange(g: BluetoothGatt, status: Int, newState: Int) {
                if (newState == BluetoothProfile.STATE_CONNECTED) {
                    g.discoverServices()
                    g.requestMtu(MAX_MTU)
                }
            }
            @SuppressLint("MissingPermission")
            override fun onServicesDiscovered(g: BluetoothGatt, status: Int) {
                val s = g.getService(SERVICE_UUID) ?: return
                val rx = s.getCharacteristic(CHAR_RX_UUID) ?: return
                g.setCharacteristicNotification(rx, true)
            }
        })
    }

    @SuppressLint("MissingPermission")
    fun broadcastFrame(json: String) {
        val d = connectedDevice ?: return
        val rx = rxCharacteristic ?: return
        rx.value = json.toByteArray(Charsets.UTF_8)
        gattServer?.notifyCharacteristicChanged(d, rx, false)
    }

    @SuppressLint("MissingPermission")
    fun stop() {
        try {
            adapter?.bluetoothLeAdvertiser?.stopAdvertising(advertiseCallback)
            adapter?.bluetoothLeScanner?.stopScan(object : ScanCallback() {})
            gattServer?.close()
            gattClient?.close()
        } catch (_: Exception) {}
    }
}

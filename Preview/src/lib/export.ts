import { fleetbox } from './generated/export'

export type IExportEnvelope = fleetbox.export_.IExportEnvelope
export type IBackupExport = fleetbox.export_.IBackupExport
export type IVehicle = fleetbox.export_.IVehicle
export type ILogItem = fleetbox.export_.ILogItem
export type ILineItem = fleetbox.export_.ILineItem
export type ILineItemField = fleetbox.export_.ILineItemField
export type IOdometerReading = fleetbox.export_.IOdometerReading
export type IAttachment = fleetbox.export_.IAttachment
export type IShop = fleetbox.export_.IShop
export type ITireSet = fleetbox.export_.ITireSet
export type IWarranty = fleetbox.export_.IWarranty

export function encodeExportEnvelope(exportEnvelope: IExportEnvelope): ArrayBuffer {
    return fleetbox.export_.ExportEnvelope.encode(exportEnvelope).finish().buffer
}

export function decodeExportEnvelope(buf: ArrayBuffer): IExportEnvelope {
    return fleetbox.export_.ExportEnvelope.decode(new Uint8Array(buf))
}

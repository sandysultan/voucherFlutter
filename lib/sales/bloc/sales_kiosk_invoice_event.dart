part of 'sales_kiosk_invoice_bloc.dart';

abstract class SalesKioskInvoiceEvent extends Equatable {
  const SalesKioskInvoiceEvent();

  @override
  List<Object?> get props => [];
}

class UpdateKioskWhatsapp extends SalesKioskInvoiceEvent{
  final Kiosk kiosk;


  const UpdateKioskWhatsapp(this.kiosk);

  @override
  List<Object?> get props => [kiosk];

}
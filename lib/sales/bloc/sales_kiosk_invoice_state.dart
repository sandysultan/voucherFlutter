part of 'sales_kiosk_invoice_bloc.dart';

abstract class SalesKioskInvoiceState extends Equatable {
  const SalesKioskInvoiceState();

  @override
  List<Object> get props => [];
}

class SalesKioskInvoiceInitial extends SalesKioskInvoiceState {
  @override
  List<Object> get props => [];
}

class UpdateWhatsappSuccess extends SalesKioskInvoiceState {
  final Kiosk kiosk;

  const UpdateWhatsappSuccess(this.kiosk);

  @override
  List<Object> get props => [kiosk];
}

class UpdateWhatsappLoading extends SalesKioskInvoiceState {
}

class UpdateWhatsappError extends SalesKioskInvoiceState {
  final String message;

  const UpdateWhatsappError(this.message);

  @override
  List<Object> get props => [message];
}

import 'package:flutter/material.dart';

class HistoryTransactions {
	bool? success;
	String? message;
	List<Data>? data;
	Error? error;

	HistoryTransactions({this.success, this.message, this.data, this.error});

	HistoryTransactions.fromJson(Map<String, dynamic> json) {
		success = json['success'];
		message = json['message'];
		if (json['data'] != null) {
			data = <Data>[];
			json['data'].forEach((v) { data!.add(new Data.fromJson(v)); });
		}
		error = json['error'] != null ? new Error.fromJson(json['error']) : null;
	}

	Map<String, dynamic> toJson() {
		final Map<String, dynamic> data = new Map<String, dynamic>();
		data['success'] = this.success;
		data['message'] = this.message;
		if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
		if (this.error != null) {
      data['error'] = this.error!.toJson();
    }
		return data;
	}
}

class Data {
	String? date;
	int? total;
	List<Transactions>? transactions;

	Data({this.date, this.total, this.transactions});

	Data.fromJson(Map<String, dynamic> json) {
		date = json['date'];
		total = json['total'];
		if (json['transactions'] != null) {
			transactions = <Transactions>[];
			json['transactions'].forEach((v) { transactions!.add(new Transactions.fromJson(v)); });
		}
	}

	Map<String, dynamic> toJson() {
		final Map<String, dynamic> data = new Map<String, dynamic>();
		data['date'] = this.date;
		data['total'] = this.total;
		if (this.transactions != null) {
      data['transactions'] = this.transactions!.map((v) => v.toJson()).toList();
    }
		return data;
	}
}

class Transactions {
	String? name;
	int? amount;

	Transactions({this.name, this.amount});

	Transactions.fromJson(Map<String, dynamic> json) {
		name = json['name'];
		amount = json['amount'];
	}

	Map<String, dynamic> toJson() {
		final Map<String, dynamic> data = new Map<String, dynamic>();
		data['name'] = this.name;
		data['amount'] = this.amount;
		return data;
	}
}

class Error {


	Error();

	Error.fromJson(Map<String, dynamic> json) 
  {
	}

	Map<String, dynamic> toJson() {
		final Map<String, dynamic> data = new Map<String, dynamic>();
		return data;
	}
}

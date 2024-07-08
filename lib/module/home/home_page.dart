import 'package:catat_keuangan/helper/dimensions.dart';
import 'package:catat_keuangan/module/authentication/signin_page.dart';
import 'package:catat_keuangan/module/transaction/transaction_bloc.dart';
import 'package:catat_keuangan/module/transaction/transaction_event.dart';
import 'package:catat_keuangan/module/transaction/transaction_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  final FirebaseFirestore firestore;
  final FirebaseAuth firebaseauth;

  HomePage({required this.firestore, required this.firebaseauth});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _selectedValue;
  final List<String> _dropdownItems = ['Pemasukan', 'Pengeluaran'];
  bool _isDarkMode = false; // State to track dark mode
  int _selectedIndex = 0; // State to track selected bottom nav item
  DateTimeRange? _selectedDateRange; // State to track selected date range
DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
  }

  Future<void> _logout(BuildContext context) async {
    bool confirmLogout = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Konfirmasi Logout"),
          content: const Text("Apakah Anda yakin ingin logout?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("Batal"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text("Logout"),
            ),
          ],
        );
      },
    );

    if (confirmLogout ?? false) {
      await FirebaseAuth.instance.signOut();

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SignInPage()),
      );
    }
  }

  void _toggleDarkMode() {
    setState(() {
      _isDarkMode = !_isDarkMode;
      if (_isDarkMode) {
        ThemeMode.dark;
      } else {
        ThemeMode.light;
      }
    });
  }

  final currencyFormatter =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp');

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      context.read<TransactionBloc>().add(LoadTransactions());
    } else if (index == 1) {
      _showAddTransactionSheet(context);
    } else if (index == 2) {
      _logout(context);
    }
  }

  void _showFilterOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Hari ini'),
                onTap: () {
                  final now = DateTime.now();
                  final startOfDay = DateTime(now.year, now.month, now.day);
                  final endOfDay = startOfDay
                      .add(const Duration(days: 1))
                      .subtract(const Duration(seconds: 1));
                  setState(() {
                    _selectedDateRange =
                        DateTimeRange(start: startOfDay, end: endOfDay);
                  });
                  context.read<TransactionBloc>().add(FilterTransactions(
                      startDate: startOfDay, endDate: endOfDay));
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Minggu ini'),
                onTap: () {
                  final now = DateTime.now();
                  final startOfWeek =
                      now.subtract(Duration(days: now.weekday - 1));
                  final endOfWeek = startOfWeek
                      .add(const Duration(days: 7))
                      .subtract(const Duration(seconds: 1));
                  setState(() {
                    _selectedDateRange =
                        DateTimeRange(start: startOfWeek, end: endOfWeek);
                  });
                  context.read<TransactionBloc>().add(FilterTransactions(
                      startDate: startOfWeek, endDate: endOfWeek));
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Bulan ini'),
                onTap: () {
                  final now = DateTime.now();
                  final startOfMonth = DateTime(now.year, now.month);
                  final endOfMonth = DateTime(now.year, now.month + 1)
                      .subtract(const Duration(seconds: 1));
                  setState(() {
                    _selectedDateRange =
                        DateTimeRange(start: startOfMonth, end: endOfMonth);
                  });
                  context.read<TransactionBloc>().add(FilterTransactions(
                      startDate: startOfMonth, endDate: endOfMonth));
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Custom'),
                onTap: () async {
                  final dateRange = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (dateRange != null) {
                    setState(() {
                      _selectedDateRange = dateRange;
                    });
                    context.read<TransactionBloc>().add(FilterTransactions(
                        startDate: dateRange.start, endDate: dateRange.end));
                    Navigator.pop(context);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          TransactionBloc(widget.firestore, widget.firebaseauth)
            ..add(LoadTransactions()),
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text(
            "Catatan\nPemasukan Dan Pengeluaran",
            style: TextStyle(),
            textAlign: TextAlign.start,
          ),
          actions: [
            IconButton(
              onPressed: _toggleDarkMode,
              icon: Icon(
                _isDarkMode ? Icons.light_mode : Icons.dark_mode,
              ),
            ),
            IconButton(
              onPressed: () => _showFilterOptions(context),
              icon: const Icon(Icons.filter_list),
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            context.read<TransactionBloc>().add(LoadTransactions());
          },
          child: Column(
            children: [
              Expanded(
                child: BlocBuilder<TransactionBloc, TransactionState>(
                  builder: (context, state) {
                    if (state is TransactionLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is TransactionLoaded) {
                      if (state.transactions.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Lottie.asset(
                                "assets/lottie/data_no_found.json",
                                frameRate: FrameRate(60),
                                width: Dimensions.size100 * 2,
                                repeat: true,
                              ),
                              Text(
                                "Tidak ada data yang ditemukan\nBuat Catatan Untuk Menambahkan Data",
                                style: TextStyle(
                                  fontSize: Dimensions.text20,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      }

                      // Sort transactions by date in descending order
                      state.transactions.sort((a, b) {
                        return b['tanggal']
                            .toDate()
                            .compareTo(a['tanggal'].toDate());
                      });

                      // Calculate total pemasukan dan pengeluaran
                      double totalPemasukan = 0;
                      double totalPengeluaran = 0;
                      for (var transaction in state.transactions) {
                        if (transaction['tipe'] == 'Pemasukan') {
                          totalPemasukan += transaction['jumlah'];
                        } else if (transaction['tipe'] == 'Pengeluaran') {
                          totalPengeluaran += transaction['jumlah'];
                        }
                      }

                      return Column(
                        children: [
                          Expanded(
                            child: ListView.builder(
                              itemCount: state.transactions.length,
                              itemBuilder: (context, index) {
                                final transaction = state.transactions[index];
                                final transactionId = transaction['id'];
                                return Dismissible(
                                  key: Key(
                                      transactionId ?? UniqueKey().toString()),
                                  direction: DismissDirection.endToStart,
                                  background: Container(
                                    color: Colors.red,
                                    alignment: Alignment.centerRight,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20),
                                    child: const Icon(Icons.delete,
                                        color: Colors.white),
                                  ),
                                  confirmDismiss: (direction) async {
                                    return await showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text("Konfirmasi"),
                                          content: const Text(
                                              "Apakah Anda yakin ingin menghapus catatan ini?"),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(context)
                                                      .pop(false),
                                              child: const Text("Batal"),
                                            ),
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(context)
                                                      .pop(true),
                                              child: const Text("Hapus"),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  onDismissed: (DismissDirection direction) {
                                    if (transactionId != null) {
                                      // Hapus item dari daftar dan dari Firebase
                                      context.read<TransactionBloc>().add(
                                          DeleteTransaction(
                                              transactionId: transactionId));
                                    }
                                  },
                                  child: Column(
                                    children: [
                                      Card(
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 8, horizontal: 16),
                                        child: ListTile(
                                          leading: Icon(
                                            transaction['tipe'] == 'Pemasukan'
                                                ? Icons.arrow_circle_up
                                                : Icons.arrow_circle_down,
                                            color: transaction['tipe'] ==
                                                    'Pemasukan'
                                                ? Colors.green
                                                : Colors.red,
                                          ),
                                          title: Text(
                                            '${transaction['tipe']}: ${currencyFormatter.format(transaction['jumlah'])}',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          subtitle:
                                              Text(transaction['deskripsi']),
                                          trailing: Text(
                                            DateFormat('dd MMMM yyyy HH:mm:ss')
                                                .format(transaction['tanggal']
                                                    .toDate()),
                                            style: const TextStyle(
                                                color: Colors.grey),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 16, horizontal: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Pemasukan',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18),
                                    ),
                                    Text(
                                      currencyFormatter.format(totalPemasukan),
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Pengeluaran',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18),
                                    ),
                                    Text(
                                      currencyFormatter
                                          .format(totalPengeluaran),
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    } else if (state is TransactionError) {
                      return Center(child: Text(state.error));
                    }
                    return const Center(
                        child: Text('Tidak ada transaksi ditemukan'));
                  },
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add),
              label: 'Tambah Catatan',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.logout),
              label: 'Logout',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.amber[800],
          onTap: _onItemTapped,
        ),
      ),
    );
  }

 void _showAddTransactionSheet(BuildContext context) {
  final TextEditingController amountController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  String? selectedType = _dropdownItems[0]; // Default to the first item

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Tambah Data Pemasukan/Pengeluaran',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: amountController,
                  decoration: const InputDecoration(
                    labelText: 'Biaya Pengeluaran/Pemasukan',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Deskripsi',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Tanggal: ${DateFormat('dd MMMM yyyy').format(_selectedDate)}',
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        final DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (pickedDate != null && pickedDate != _selectedDate) {
                          setState(() {
                            _selectedDate = pickedDate;
                          });
                        }
                      },
                      icon: Icon(Icons.calendar_today),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedType,
                  items: _dropdownItems.map((String newValue) {
                    return DropdownMenuItem<String>(
                      value: newValue,
                      child: Text(newValue),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      selectedType = newValue;
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: 'Tipe',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    final amount = double.parse(amountController.text);
                    final description = descriptionController.text;
                    final type = selectedType!;
                    final date = _selectedDate;

                    context.read<TransactionBloc>().add(
                          AddTransaction(
                            type: type,
                            amount: amount,
                            description: description,
                            date: date,
                          ),
                        );

                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.save),
                  label: const Text('Simpan'),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
}

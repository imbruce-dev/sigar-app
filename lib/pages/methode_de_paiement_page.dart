import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'add_card_page.dart'; // Importer la page pour ajouter une carte

class PaymentMethodsPage extends StatefulWidget {
  const PaymentMethodsPage({Key? key}) : super(key: key);

  @override
  _PaymentMethodsPageState createState() => _PaymentMethodsPageState();
}

class _PaymentMethodsPageState extends State<PaymentMethodsPage> {
  List<Map<String, String>> paymentMethods = []; // Liste des méthodes de paiement

  void _addPaymentMethod(Map<String, String> method) {
    setState(() {
      paymentMethods.add(method);
    });
  }

  void _showAddPaymentModal() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SizedBox(
          height: 200,
          child: Column(
            children: [
              ListTile(
                leading: SvgPicture.asset(
                  'lib/assets/svg/logos--visa.svg',
                  width: 20,
                  height: 15.5, // Adapter la taille pour garder un bon ratio
                ),
                title: const Text('Visa'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddCardPage(
                        type: 'Visa',
                        logoPath: 'lib/assets/svg/logos--visa.svg',
                        onAdd: _addPaymentMethod,
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                leading: SvgPicture.asset(
                  'lib/assets/svg/logos--mastercard.svg',
                  width: 20,
                  height: 15.5, // Adapter la taille pour garder un bon ratio
                ),
                title: const Text('MasterCard'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddCardPage(
                        type: 'MasterCard',
                        logoPath: 'lib/assets/svg/logos--mastercard.svg',
                        onAdd: _addPaymentMethod,
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                leading: SvgPicture.asset(
                  'lib/assets/svg/logos--paypal.svg',
                  width: 20,
                  height: 15.5, // Adapter la taille pour garder un bon ratio
                ),
                title: const Text('PayPal'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddCardPage(
                        type: 'PayPal',
                        logoPath: 'lib/assets/svg/logos--paypal.svg',
                        onAdd: _addPaymentMethod,
                      ),
                    ),
                  );
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF013781),
        title: const Text('Méthodes de paiement', style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: paymentMethods.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Aucun moyen de paiement ajouté pour l'instant.",
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                itemCount: paymentMethods.length,
                itemBuilder: (context, index) {
                  final method = paymentMethods[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      leading: SvgPicture.asset(method['logoPath']!, width: 40, height: 31),
                      title: Text('**** **** **** ${method['last4']}'),
                      subtitle: Text('Expire ${method['expiryDate']}'),
                      trailing: TextButton(
                        onPressed: () {
                          // Ajouter la logique de modification
                        },
                        child: const Text('Modifier', style: TextStyle(color: Color(0xFF4266B5))),
                      ),
                    ),
                  );
                },
              ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: _showAddPaymentModal,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4266B5),
            padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 40.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20), // Bord arrondi léger
            ),
          ),
          child: const Text('Ajouter un moyen de paiement', style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Importation pour TextInputFormatter
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PaymentWidget extends StatefulWidget {
  final VoidCallback onPaymentSuccess;

  const PaymentWidget({Key? key, required this.onPaymentSuccess}) : super(key: key);

  @override
  _PaymentWidgetState createState() => _PaymentWidgetState();
}

class _PaymentWidgetState extends State<PaymentWidget> {
  String selectedCountry = 'France';
  String selectedPaymentMethod = 'card';
  TextEditingController emailController = TextEditingController();
  TextEditingController fullNameController = TextEditingController();
  TextEditingController cardNumberController = TextEditingController();
  TextEditingController expirationDateController = TextEditingController();
  TextEditingController securityCodeController = TextEditingController();
  bool isPaymentSuccessful = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    emailController.text = prefs.getString('userEmail') ?? '';
    fullNameController.text = '${prefs.getString('userFirstName') ?? ''} ${prefs.getString('userLastName') ?? ''}';
  }

  void _selectPaymentMethod(String method) {
    setState(() {
      selectedPaymentMethod = method;
    });
  }

  void _processPayment() {
    if (cardNumberController.text == '1234 5678 1234 5678' &&
        expirationDateController.text == '12/29' &&
        securityCodeController.text == '123') {
      setState(() {
        isLoading = true;
      });

      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          isLoading = false;
          isPaymentSuccessful = true;
        });
        widget.onPaymentSuccess(); // Appel du callback après succès
      });
    } else {
      // Handle invalid card information
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informations de carte invalides')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paiement'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.95,
            child: isPaymentSuccessful ? _buildSuccessScreen() : _buildPaymentForm(),
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Section Vos Informations
        const Text(
          'Vos Informations',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: emailController,
          decoration: InputDecoration(
            labelText: 'Email',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: fullNameController,
          decoration: InputDecoration(
            labelText: 'Full Name',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(height: 10),
        _buildCountryPicker(),
        const SizedBox(height: 20),

        // Section Paiements
        const Text(
          'Paiements',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildPaymentOption('card', 'Carte de crédit', 'lib/assets/svg/ion--card.svg'),
            _buildPaymentOption('paypal', 'PayPal', 'lib/assets/svg/fontisto--paypal.svg'),
            _buildPaymentOption('bank', 'Bank', 'lib/assets/svg/mingcute--bank-line.svg'),
          ],
        ),
        const SizedBox(height: 20),
        if (selectedPaymentMethod == 'card') _buildCardInformationSection(),
        const SizedBox(height: 20),
        if (selectedPaymentMethod == 'card')
          ElevatedButton(
            onPressed: isLoading ? null : _processPayment,
            child: isLoading
                ? const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  )
                : const Text('Payer', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4266B5),
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSuccessScreen() {
    return AnimatedOpacity(
      opacity: isPaymentSuccessful ? 1.0 : 0.0,
      duration: const Duration(seconds: 1),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset('lib/assets/images/paymentsuccess.svg', height: 100),
            const SizedBox(height: 20),
            const Text(
              'Paiement Réussi',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text('5 euro payé avec succès'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: widget.onPaymentSuccess,
              child: const Text('Afficher les PV'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4266B5),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountryPicker() {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          builder: (BuildContext context) {
            return Column(
              children: [
                const ListTile(
                  title: Text('Choisissez votre pays', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                ListTile(
                  leading: Image.asset('lib/assets/images/france_flag.png', width: 30),
                  title: const Text("France"),
                  onTap: () {
                    setState(() {
                      selectedCountry = "France";
                    });
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: Image.asset('lib/assets/images/luxembourg_flag.png', width: 30),
                  title: const Text("Luxembourg"),
                  onTap: () {
                    setState(() {
                      selectedCountry = "Luxembourg";
                    });
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          },
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey),
        ),
        child: Row(
          children: [
            Image.asset(
              selectedCountry == "France"
                  ? 'lib/assets/images/france_flag.png'
                  : 'lib/assets/images/luxembourg_flag.png',
              width: 30,
            ),
            const SizedBox(width: 10),
            Text(selectedCountry),
            const Spacer(),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption(String method, String label, String iconPath) {
    bool isSelected = selectedPaymentMethod == method;
    return GestureDetector(
      onTap: () => _selectPaymentMethod(method),
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? const Color(0xFF4266B5) : Colors.grey),
        ),
        child: Column(
          children: [
            SvgPicture.asset(
              iconPath,
              color: isSelected ? const Color(0xFF4266B5) : Colors.black,
              height: 40,
            ),
            const SizedBox(height: 5),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xFF4266B5) : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardInformationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Informations de la carte',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: cardNumberController,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(19), // Limite à 19 caractères (16 chiffres + 3 espaces)
            CardNumberInputFormatter(), // Formattage personnalisé
          ],
          decoration: InputDecoration(
            labelText: 'Numéro de carte',
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset('lib/assets/svg/logos--visa.svg', height: 20),
                const SizedBox(width: 5),
                SvgPicture.asset('lib/assets/svg/logos--mastercard.svg', height: 20),
              ],
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: expirationDateController,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(5), // Limite à 5 caractères (MM/YY)
                  ExpirationDateInputFormatter(), // Formattage personnalisé
                ],
                decoration: InputDecoration(
                  labelText: 'Expiration date',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: securityCodeController,
                decoration: InputDecoration(
                  labelText: 'Security code',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// Classe pour formater le numéro de carte
class CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    String newText = newValue.text.replaceAll(' ', ''); // Supprime les espaces
    if (newText.isEmpty) return TextEditingValue(); // Si vide, retourne vide

    // Ajoute un espace après chaque 4 chiffres
    StringBuffer buffer = StringBuffer();
    for (int i = 0; i < newText.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(newText[i]);
    }
    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}

// Classe pour formater la date d'expiration
class ExpirationDateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    String newText = newValue.text.replaceAll('/', ''); // Supprime les barres
    if (newText.isEmpty) return TextEditingValue(); // Si vide, retourne vide

    // Ajoute une barre après les 2 premiers chiffres
    StringBuffer buffer = StringBuffer();
    for (int i = 0; i < newText.length; i++) {
      if (i == 2) buffer.write('/'); // Ajoute la barre
      buffer.write(newText[i]);
    }
    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}
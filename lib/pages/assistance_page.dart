import 'package:flutter/material.dart';
import 'discussion_page.dart'; // Importing the new DiscussionPage

class AssistancePage extends StatefulWidget {
  const AssistancePage({super.key});

  @override
  _AssistancePageState createState() => _AssistancePageState();
}

class _AssistancePageState extends State<AssistancePage> {
  bool _showAllFAQs = false; // Boolean to toggle FAQ expansion

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assistance'),
        backgroundColor: const Color(0xFF013781),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title with flame emoji
            const Row(
              children: [
                Expanded(
                  child: Text(
                    "Vous avez une question brûlante? ",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  "🔥",
                  style: TextStyle(fontSize: 20),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Search bar
            TextField(
              decoration: InputDecoration(
                hintText: 'Rechercher un sujet ou une question',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                prefixIcon: const Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 20),

            // Frequently Asked section
            Row(
              children: [
                const Expanded(
                  child: Text(
                    "Questions fréquemment demandées",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _showAllFAQs = !_showAllFAQs; // Toggle between expanded/collapsed
                    });
                  },
                  child: Text(
                    _showAllFAQs ? "Voir moins" : "Voir tout",
                    style: const TextStyle(color: Color(0xFF013781)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // FAQ Boxes (with go-and-back animation)
            AnimatedCrossFade(
              firstChild: _buildFAQList(context, false), // Show limited FAQs
              secondChild: _buildFAQList(context, true),  // Show all FAQs
              crossFadeState:
                  _showAllFAQs ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
            ),
            const SizedBox(height: 20),

            // Topics section
            const Row(
              children: [
                Expanded(
                  child: Text(
                    "Sujets",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  "Voir tout",
                  style: TextStyle(color: Color(0xFF013781)),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Topics List
            _buildTopicItem(context, "Retours et remboursements", "12 articles"),
            _buildTopicItem(context, "Livraison et expédition", "8 articles"),
            _buildTopicItem(context, "Paiements", "6 articles"),
            const SizedBox(height: 20),

            // Start a Conversation Button
            Container(
              alignment: Alignment.center,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.chat), // Placeholder for the chat icon
                label: const Text("Démarrer une conversation"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF013781), // Background color
                  foregroundColor: Colors.white, // Text color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DiscussionPage(
                        userName: 'Monsieur/Madame', // Replace with actual user name
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Function to build the FAQ list
  Widget _buildFAQList(BuildContext context, bool showAll) {
    List<String> questions = [
      "Comment puis-je ajouter un véhicule?",
      "Quels sont les moyens de paiement disponibles?",
      "Comment vérifier les PV?",
      "Comment modifier mes informations personnelles?",
      "Comment supprimer un véhicule?",
      "Quelles sont les sanctions pour non-paiement d'un PV?",
      "Comment récupérer mon mot de passe?",
      "Quelles options de support sont disponibles?",
    ];

    return SizedBox(
      height: 120,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          for (int i = 0; i < (showAll ? questions.length : 3); i++)
            _buildFAQBox(context, questions[i]),
        ],
      ),
    );
  }

  // Widget for building each FAQ box
  Widget _buildFAQBox(BuildContext context, String question) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: const LinearGradient(
          colors: [Color(0xFF013781), Color(0xFF64B5F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Text(
          question,
          textAlign: TextAlign.left, // Align text to the left
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14, // Reduced font size
          ),
        ),
      ),
    );
  }

  // Widget for building topic items
  Widget _buildTopicItem(BuildContext context, String topic, String articles) {
    return ListTile(
      leading: const Icon(Icons.article, color: Color(0xFF013781)),
      title: Text(topic),
      subtitle: Text(articles),
      onTap: () {
        // Navigate to the topic's articles
        print("Navigating to $topic");
      },
    );
  }
}

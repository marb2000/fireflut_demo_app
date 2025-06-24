import 'package:flutter/material.dart';
import '../view_models/my_stuff_view_model.dart';

class MyStuffScreen extends StatelessWidget {
  final MyStuffViewModel viewModel;

  const MyStuffScreen({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Stuff'),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline),
            onPressed: () {
              viewModel.navigateToChat(
                context,
                const Placeholder(),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: 150,
                width: double.infinity,
                color: Theme.of(context).secondaryHeaderColor,
                child: Center(
                    child: Icon(Icons.card_giftcard,
                        size: 70, color: Theme.of(context).primaryColor)),
              ),
              const SizedBox(height: 20),
              Text('You don\'t have any saved deals',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 10),
              const Text('Check out this week\'s deals and get to saving'),
              const SizedBox(height: 20),
              ExpansionTile(
                title: const Text('Expired'),
                children: [
                  ListTile(
                    title: const Text('No expired deals'),
                    onTap: () {},
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

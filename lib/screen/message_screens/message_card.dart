import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gis_osm/data/models/message.dart';
import 'package:gis_osm/services/firebase_apis.dart';

class MessageCard extends StatefulWidget {
  const MessageCard({super.key, required this.message});

  final Message message;

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    return FirebaseAPIService.user.uid == widget.message.senderId
        ? _buildSenderCard()
        : _buildReceiverCard();
  }

  Widget _buildSenderCard() {
    return Card(
      color: Colors.blue,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(widget.message.content),
      ),
    );
  }

  Widget _buildReceiverCard() {
    return Card(
      color: Colors.green,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(widget.message.content),
      ),
    );
  }
}

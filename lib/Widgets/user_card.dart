import 'package:flutter/material.dart';
import 'package:spotfinder/Resources/pallete.dart';
import 'package:spotfinder/Services/UserService.dart';

late UserService userService;

class UserCard extends StatefulWidget {
  final String? name;
  final String? image;
  const UserCard(
    this.name,
    this.image, {
    super.key,
  });

  @override
  // ignore: library_private_types_in_public_api
  _UserCard createState() => _UserCard();
}

class _UserCard extends State<UserCard> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          color: Pallete.backgroundColor,
          surfaceTintColor: Pallete.accentColor,
          elevation: 5,
          margin: EdgeInsets.all(5),
          child: Row(
            children: [
              // Left side: Image
              Container(
                  margin: EdgeInsets.all(8),
                  width: 65,
                  height: 65,
                  child: widget.image == null
                      ? Icon(
                          Icons.person,
                          size: 32,
                          color: Pallete.paleBlueColor,
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(12), 
                          child: Image.network(
                            widget.image!,
                            fit: BoxFit.cover,
                          ),
                        )),
              // Right side: Title, Description, and Value
              const SizedBox(width: 15),
              Text(
                widget.name ?? 'NAME',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Pallete.textColor),
              ),
            ],
          ),
        ),
        // Add other widgets below if needed
      ],
    );
  }
}

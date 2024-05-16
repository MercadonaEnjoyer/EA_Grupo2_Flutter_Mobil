import 'package:flutter/material.dart';
import 'package:spotfinder/Resources/pallete.dart';
import 'package:spotfinder/Widgets/paramTextBox.dart';
import 'package:spotfinder/Screens/activity_list_page.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'profile_screen.dart';
import 'chatScreen.dart';

class HomePage extends StatefulWidget {
  // ignore: prefer_const_constructors_in_immutables
  HomePage({super.key});

  @override
  State<HomePage> createState() => _nameState();
}

// ignore: camel_case_types
class _nameState extends State<HomePage> {
  static HomeController homeController = Get.put(HomeController());
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    Align(
      alignment: Alignment.topCenter,
      child: Column(
        children: [
          SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment:
                MainAxisAlignment.center, // Centers widgets horizontally
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ParamTextBox(
                  controller: homeController.searchBarController,
                  text: 'Scaperoom...'),
              IconButton(
                icon: const Icon(
                    size: 40,
                    color: Pallete.backgroundColor,
                    LineIcons.searchLocation),
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
        ],
      ),
    ),
    const ActivityListPage(),
    const ChatScreen(),
    const ProfileScreen()
  ];

  @override
  Widget build(BuildContext context) {
    const gradientStart = Colors.black;
    const gradientEnd = Colors.transparent;

    final _gradient = LinearGradient(
        colors: [gradientStart, gradientEnd],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        stops: [0, 0.3]);

    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Pallete.backgroundColor,
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              color: Pallete.backgroundColor.withOpacity(0.1),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: GNav(
              padding: EdgeInsets.all(10),
              tabBorderRadius: 10,
              rippleColor: Colors.grey[300]!,
              hoverColor: Colors.grey[100]!,
              gap: 0,
              activeColor: Pallete.salmonColor,
              iconSize: 24,
              tabBackgroundColor: Colors.grey[100]!,
              color: Pallete.whiteColor,
              tabs: const [
                GButton(
                    iconColor: Colors.white,
                    icon: LineIcons.mapMarker,
                    text: "Home"),
                GButton(
                    iconColor: Colors.white,
                    icon: LineIcons.hiking,
                    text: "Activities"),
                GButton(
                    iconColor: Colors.white,
                    icon: LineIcons.comment,
                    text: "Chats"),
                GButton(
                    iconColor: Colors.white,
                    icon: LineIcons.user,
                    text: "Profile"),
              ],
              selectedIndex: _selectedIndex,
              onTabChange: (index) {
                setState(() {
                  _selectedIndex = index;
                });
                if (index == 2) {
                  // Si se selecciona la pestaña de chats, cambiar a la pantalla de chat
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ChatScreen()),
                  );
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}

class HomeController extends GetxController {
  final TextEditingController searchBarController = TextEditingController();
}

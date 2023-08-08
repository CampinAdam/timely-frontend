import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:provider/provider.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timely/controllers/account_controller.dart';

import 'intro_screen.dart';
import 'controllers/settings_controller.dart';
import 'helpers.dart';
import 'login.dart';
import 'models/settings_model.dart';
import 'notifications.dart';

/// The file that is in charge of organizing widgets for our Settings View
/// Include such things selecting priorities, alarms, and preferences.
/// All of it is currently placeholders, which will soon change.

/// Makes our settings widget stateful
class Settings extends StatelessWidget {
  const Settings({super.key});
  @override
  Widget build(BuildContext context) {


    final SettingsProvider settingsProvider =
        Provider.of<SettingsProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SettingsList(
        sections: [
          SettingsSection(title: const Text("General"), tiles: [
            SettingsTile.switchTile(
              title: const Text('Dark Mode'),
              leading: const Icon(Icons.dark_mode),
              initialValue: settingsProvider.darkTheme,
              onToggle: (bool value) {
                settingsProvider.darkTheme = value;
              },
            ),
            SettingsTile.navigation(
                title: const Text('Linked Accounts'),
                leading: const Icon(Icons.link),
                trailing: const Icon(Icons.arrow_right),
                onPressed: (context) => Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return Scaffold(
                          appBar: AppBar(
                            title: const Text('Linked Accounts'),
                          ),
                          body: Center(
                              child: SettingsList(sections: [
                            SettingsSection(
                                title: const Text("Accounts"),
                                tiles: [
                                  providerAccount(
                                      "google.com", "Google", context),
                                  providerAccount(
                                      "apple.com", "Apple", context),
                                  providerAccount(
                                      "microsoft.com", "Microsoft", context)
                                ])
                          ])));
                    })))
          ]),
          SettingsSection(
            title: const Text('Defaults'),
            tiles: [
              SettingsTile(
                  description: Text(
                    SettingsController().settingsModel.homeAddress ??
                        "No Address Set",
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  title: const Text('Home Address'),
                  leading: const Icon(Icons.home),
                  trailing: const Icon(Icons.arrow_right),
                  onPressed: (BuildContext context) async {
                    await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return _homeAddressDialog(context);
                        });
                  }),
              SettingsTile(
                title: const Text('Transportation'),
                leading: settingsProvider.transportMode.icon,
                trailing: DropdownButton<String>(
                  value: settingsProvider.transportMode.description,
                  icon: const Icon(Icons.arrow_downward),
                  iconSize: 24,
                  elevation: 16,
                  onChanged: (String? value) {
                    settingsProvider.transportMode =
                        TransportMode.fromString(value!);
                  },
                  items: TransportMode.values
                      .map((TransportMode transportMode) =>
                          transportMode.description)
                      .map(_dropdownMenuItemFromString)
                      .toList(),
                ),
              ),
            ],
          ),
          SettingsSection(
            title: const Text('Notifications'),
            tiles: [
              SettingsTile(
                title: const Text('Get Ready'),
                leading: const Icon(FontAwesome.fire),
                trailing: DropdownButton<int>(
                  value: settingsProvider.getReadyMinutes,
                  icon: const Icon(Icons.arrow_downward),
                  iconSize: 24,
                  elevation: 16,
                  onChanged: (int? value) {
                    settingsProvider.getReadyMinutes = value!;
                  },
                  items: SettingsProvider.getReadyMinutePossibilities
                      .map((int poss) => DropdownMenuItem<int>(
                          value: poss, child: Text("$poss Minutes")))
                      .toList(),
                ),
              ),
              SettingsTile(
                title: const Text('Arrive Early'),
                leading: const Icon(LineAwesome.ribbon_solid),
                trailing: DropdownButton<int>(
                  value: settingsProvider.arriveEarlyMinutes,
                  icon: const Icon(Icons.arrow_downward),
                  iconSize: 24,
                  elevation: 16,
                  onChanged: (int? value) {
                    settingsProvider.arriveEarlyMinutes = value!;
                  },
                  items: SettingsProvider.arriveEarlyMinutePossibilities
                      .map((int poss) => DropdownMenuItem<int>(
                          value: poss, child: Text("$poss Minutes")))
                      .toList(),
                ),
              ),
            ],
          ),
          SettingsSection(
            title: const Text('Account'),
            tiles: [
              SettingsTile.navigation(
                  title: const Text('Sign Out'),
                  leading: const Icon(Icons.logout),
                  onPressed: (context) {
                    Provider.of<AccountController>(context, listen: false)
                        .signOut();

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const Login()),
                    );
                    Fluttertoast.showToast(
                        msg: "Successful Logout",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM);
                  }),

              SettingsTile.navigation(
                  title: const Text('Delete Account Permanently'),
                  leading: const Icon(FontAwesome.user_minus),
                  onPressed: (context) {
                    _confirmDeleteAccount(context);
                  }),

              SettingsTile.navigation(
                  title: const Text('Show Tutorial'),
                  leading: const Icon(FontAwesome.circle_play),
                  onPressed: (context) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const IntroScreen()),
                    );
                  }),

              SettingsTile(
                  title: const Text('Notif'),
                  leading: const Icon(Icons.notifications_active),
                  onPressed: (context) async{
                    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
                    await initialize(flutterLocalNotificationsPlugin);
                    await scheduleEventNotification(
                        title: "Uh Oh Time to run",
                        body: "Head to your meeting, right now",
                        fln: flutterLocalNotificationsPlugin,
                        whenToGo: DateTime.now().add(const Duration(seconds: 30)));
                  }
              )

              // Delete Firebase Account is currently in signOut().
            ],
          ),
        ],
      ),
    );
  }

  DropdownMenuItem<String> _dropdownMenuItemFromString(String string) {
    return _dropdownMenuItemFromText(Text(string));
  }

  DropdownMenuItem<String> _dropdownMenuItemFromText(Text text) {
    return DropdownMenuItem<String>(value: text.data, child: text);
  }

  Widget _homeAddressDialog(BuildContext context) {
    String? home = SettingsController().settingsModel.homeAddress;

    return StatefulBuilder(builder: (context, setState) {
      return AlertDialog(
          actionsPadding: const EdgeInsets.all(16.0),
          contentPadding: const EdgeInsets.all(16.0),
          buttonPadding: const EdgeInsets.all(16.0),
          insetPadding: const EdgeInsets.all(32.0),
          icon: const Icon(Icons.home),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0),
          ),
          elevation: 1,
          title: const Text('Home Address'),
          content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.height * 0.2,
              child: Flex(direction: Axis.vertical, children: <Widget>[
                const Text("Edit your home address:"),
                const Spacer(),
                TextField(
                    showCursor: false,
                    maxLines: 1,
                    controller: TextEditingController(text: home),
                    onTap: () {
                      getLocationUsingPlacesAutocomplete(context)
                          .then((value) => {
                                setState(() {
                                  home = value;
                                })
                              });
                      //setState(() {});
                    },
                    decoration: InputDecoration(
                      suffixIcon: home != null
                          ? IconButton(
                              onPressed: () {
                                setState(() {
                                  home = "";
                                });
                              },
                              icon: const Icon(Icons.cancel),
                            )
                          : null,
                      contentPadding:
                          const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.blueAccent.shade100, width: 2.0),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      filled: true,
                      hintStyle: TextStyle(color: Theme.of(context).hintColor),
                      hintText: "1234 Main St, City, State, Zip",
                    )),
                const Spacer(),
                Row(children: [
                  const Spacer(flex: 1),
                  TextButton(
                      child: const Text("Cancel"),
                      onPressed: () {
                        Navigator.of(context).pop();
                      }),
                  const Spacer(flex: 5),
                  TextButton(
                      child: const Text("Confirm"),
                      onPressed: () {
                        if (home != null) {
                          SettingsController().settingsModel.homeAddress = home;
                          SettingsController().save();
                          Fluttertoast.showToast(
                              msg: "Home address set",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM);
                        } else {
                          Fluttertoast.showToast(
                              msg: "Failed to set home address",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM);
                        }
                        Navigator.of(context).pop();
                      }),
                  const Spacer(flex: 1),
                ])
              ])));
    });
  }

  void _confirmDeleteAccount(BuildContext context) {
    showDialog(
        barrierDismissible: true,
        useSafeArea: true,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: const Text("Delete Account Permanently",
                  textAlign: TextAlign.center),
              content: const Text(
                  "Are you sure you want to delete your account?"
                  "\nDoing this will permanently remove all user information from the system.",
                  textAlign: TextAlign.center),
              actions: [
                TextButton(
                    child: const Text("Delete", textAlign: TextAlign.center),
                    onPressed: () async {
                      Provider.of<AccountController>(context, listen: false)
                          .removeFromFirestore();
                      Provider.of<AccountController>(context, listen: false)
                          .signOut();
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Login()));

                      Fluttertoast.showToast(
                          msg: "Account Deleted",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM);
                    }),
                TextButton(
                    child: const Text("Cancel", textAlign: TextAlign.center),
                    onPressed: () {
                      Navigator.of(context).pop();
                    })
              ]);
        });
  }

  SettingsTile providerAccount(
    String s,
    String provider,
    BuildContext context,
  ) {
    String description = "";
    bool isLinked = false;

    FirebaseAuth auth = FirebaseAuth.instance;
    List<UserInfo?> p = auth.currentUser?.providerData ?? [];
    for (var u in p) {
      if (u?.providerId == s) {
        isLinked = true;
        description = u?.email ?? "Unknown";
      }
    }

    return SettingsTile(
        title: Text(provider),
        description: isLinked ? Text(description) : null,
        leading: isLinked
            ? Icon(
                Icons.check_circle_outline,
                color: Colors.greenAccent.shade200,
              )
            : Icon(Icons.circle_outlined,
                color: Theme.of(context).disabledColor),
        onPressed: (context) async {
          if (isLinked) {
            AccountController().removeAccount(s).then((value) {
              if (FirebaseAuth.instance.currentUser == null) {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => const Login()));
              }

              Fluttertoast.showToast(
                  msg: "$provider Account Deleted",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM);
            }).catchError((error) {
              Fluttertoast.showToast(
                  msg: "$provider Account Deleting Error",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM);
            });
          } else {
            AccountController().signUpOrLinkAccount(s).then((_) {
              Fluttertoast.showToast(
                  msg: "$provider Account Linked",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM);
            }).catchError((error) {
              Fluttertoast.showToast(
                  msg: "$provider Account Linking Error",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM);
              log(error.toString());
            });
          }
        }
        //Reload page to update links
        );
  }
}

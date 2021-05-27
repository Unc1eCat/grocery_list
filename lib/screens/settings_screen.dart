import 'package:flutter/material.dart';
import 'package:grocery_list/widgets/heavy_touch_button.dart';
import 'package:grocery_list/widgets/rounded_rolling_switch.dart';
import 'package:my_utilities/color_utils.dart';

class SettingsScreen extends StatelessWidget {
  Widget _buildSettingsCategory(String title, IconData icon, Widget child, BuildContext context) {
    Color color = Theme.of(context).colorScheme.onSurface.blendedWith(Theme.of(context).primaryColor, 0.1).withOpacity(0.8);
    return Stack(
      children: [
        Positioned(
          top: 18,
          left: 0,
          right: 0,
          bottom: 0,
          child: Material(
            color: Theme.of(context).scaffoldBackgroundColor.blendedWithInversion(0.035).blendedWith(Theme.of(context).primaryColor, 0.01),
            borderRadius: BorderRadius.circular(10),
            elevation: 0.6,
            child: SizedBox(),
          ),
        ),
        Positioned(
          left: 10,
          child: Row(
            children: [
              Icon(
                icon,
                size: 32,
                color: color,
              ),
              SizedBox(width: 20),
              Text(
                title,
                style: Theme.of(context).textTheme.headline5.copyWith(
                      color: color,
                    ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 50, left: 30, right: 12, bottom: 25),
          child: child,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: ListView(
            physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            children: [
              SizedBox(height: 20),
              Stack(
                children: [
                  Positioned(
                    top: 26,
                    left: 12,
                    right: 32,
                    bottom: 26,
                    child: Material(
                      color: Theme.of(context).primaryColor.withRangedHsvSaturation(0.7),
                      borderRadius: BorderRadius.circular(10),
                      shadowColor: Theme.of(context).primaryColor.withRangedHsvValue(0.8),
                      elevation: 4,
                      child: SizedBox(),
                    ),
                  ),
                  Text(
                    "Anton Bespoiasov",
                    style: Theme.of(context).textTheme.headline3,
                  ),
                  Positioned(
                    bottom: 42,
                    left: 24,
                    child: Text(
                      "antonbesp.25@gmail.com",
                      style: Theme.of(context).textTheme.headline6.copyWith(
                            fontSize: 17,
                            color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.8),
                          ),
                    ),
                  ),
                  SizedBox(height: 120),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: 36,
                      child: Text(
                        "AB",
                        style: Theme.of(context).textTheme.headline4,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 26),
              _buildSettingsCategory(
                "Account",
                Icons.person_rounded,
                Column(
                  children: [
                    HeavyTouchButton(
                      pressedScale: 0.9,
                      onPressed: () {},
                      child: Row(
                        children: [
                          // Icon(Icons.logout),
                          Text(
                            "Log out",
                            style: Theme.of(context).textTheme.caption.copyWith(color: Colors.red[300]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                context,
              ),
              SizedBox(height: 22),
              _buildSettingsCategory(
                "Look & feel",
                Icons.brush_rounded,
                Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text("Dark mode", style: Theme.of(context).textTheme.caption),
                        Spacer(),
                        RoundedRollingSwitch(
                          elevation: 2.5,
                          onChanged: (value) => null,
                          colorOff: Color(0xFFF4C755),
                          colorOn: Color(0xFF4C5FB3),
                          iconOff: Icons.wb_sunny_rounded,
                          iconOn: Icons.brightness_2_rounded,
                        ),
                      ],
                    ),
                    SizedBox(height: 14),
                    Row(
                      children: [
                        Text("Language", style: Theme.of(context).textTheme.caption),
                        Spacer(),
                        DropdownButton<int>(
                          value: 0,
                          onChanged: (value) {},
                          underline: SizedBox(),
                          style: Theme.of(context).textTheme.caption,
                          dropdownColor: Theme.of(context)
                              .scaffoldBackgroundColor
                              .blendedWithInversion(0.1)
                              .blendedWith(Theme.of(context).primaryColor, 0.035),
                          iconEnabledColor:
                              Theme.of(context).cardColor.blendedWithInversion(0.4).blendedWith(Theme.of(context).primaryColor, 0.1),
                          items: [
                            DropdownMenuItem(
                              child: Text("English"),
                              value: 0,
                            ),
                            DropdownMenuItem(
                              child: Text("Russian"),
                              value: 1,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                context,
              ),
              SizedBox(height: 22),
              _buildSettingsCategory(
                "Item tags",
                Icons.tag,
                Column(
                  children: [],
                ),
                context,
              ),
              SizedBox(height: 22),
              _buildSettingsCategory(
                "Network and storage",
                Icons.bar_chart_rounded,
                Column(
                  children: [],
                ),
                context,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:spotfinder/Resources/pallete.dart';
import 'package:spotfinder/Models/ActivityModel.dart';
import 'package:intl/intl.dart';

class ActivityCard extends StatelessWidget {
  final Activity activity;
  final Function(double, double) onUpdate;
  final bool isPast;

  ActivityCard(
    this.onUpdate,
    this.activity, {
    Key? key,
  }) : isPast = activity.date.isBefore(DateTime.now()),
       super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          color: isPast ? Pallete.backgroundColor.withOpacity(0.5) : Pallete.backgroundColor,
          surfaceTintColor: Pallete.accentColor.withOpacity(isPast ? 0.5 : 1.0),
          elevation: 5,
          margin: EdgeInsets.all(10),
          child: Row(
            children: [
              // Lado izquierdo: Imagen
              const SizedBox(width: 8),
              Container(
                width: 100,
                height: 100,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    activity.imageUrl ??
                        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTjCoUtOal33JWLqals1Wq7p6GGCnr3o-lwpQ&s',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              // Lado derecho: Título, Descripción y Valor
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activity.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Pallete.textColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Description: ${activity.description}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Pallete.textColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          RatingBarIndicator(
                            rating: activity.rate!,
                            itemBuilder: (context, index) => const Icon(
                              Icons.star,
                              size: 18,
                              color: Colors.amber,
                            ),
                            itemCount: 5,
                            itemSize: 18,
                            direction: Axis.horizontal,
                            unratedColor: Colors.blueAccent.withAlpha(50),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            activity.rate!.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.amber,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ListTile(
                        trailing: Text(
                          DateFormat('dd/MM/yyyy hh:mm a').format(activity.date.toLocal()),
                          style: TextStyle(fontSize: 15, color: Pallete.textColor),
                        ),
                        subtitle: activity.location != null
                            ? FutureBuilder<String?>(
                                future: onUpdate(activity.location!.latitude, activity.location!.longitude),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return Row(
                                      children: [
                                        const Icon(Icons.location_on, color: Colors.red, size: 17),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Loading address...',
                                          style: TextStyle(color: Pallete.textColor),
                                        ),
                                      ],
                                    );
                                  } else if (snapshot.hasError) {
                                    return Row(
                                      children: [
                                        const Icon(Icons.location_on, color: Colors.red, size: 17),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Error getting the address',
                                          style: TextStyle(color: Pallete.textColor),
                                        ),
                                      ],
                                    );
                                  } else {
                                    return Row(
                                      children: [
                                        const Icon(Icons.location_on, color: Colors.red, size: 17),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            snapshot.data ?? 'Address not found',
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(color: Pallete.textColor),
                                          ),
                                        ),
                                      ],
                                    );
                                  }
                                },
                              )
                            : Text(
                                'Address unavailable',
                                style: TextStyle(color: Pallete.textColor),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
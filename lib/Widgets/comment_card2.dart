import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:spotfinder/Models/CommentModel.dart';
import 'package:spotfinder/Models/UserModel.dart';
import 'package:spotfinder/Resources/pallete.dart';
import 'package:spotfinder/Widgets/paramTextBox_edit.dart';

class CommentCard extends StatefulWidget {
  final Comment comment;
  final User user;
  final Function(BuildContext, String, int) onDelete;
  final Function(Comment, int) onUpdate;
  final int index;
  final bool isOwner;

  const CommentCard({
    required this.comment,
    required this.user,
    required this.onDelete,
    required this.onUpdate,
    required this.index,
    required this.isOwner,
    Key? key,
  }) : super(key: key);

  @override
  _CommentCardState createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {
  bool isEditing = false;
  late TextEditingController titleController;
  late TextEditingController contentController;
  double ratingValue = 0.0;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.comment.title);
    contentController = TextEditingController(text: widget.comment.content);
    ratingValue = widget.comment.review;
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }

  void toggleEdit() {
    setState(() {
      isEditing = !isEditing;
    });
  }

  Comment getComment() {
    Comment comment = Comment(
      id: widget.comment.id,
      user: widget.comment.user,
      title: titleController.text,
      content: contentController.text,
      activity: widget.comment.activity,
      review: ratingValue,
    );
    return comment;
  }

  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          color: Pallete.primaryColor,
          surfaceTintColor: Pallete.accentColor,
          elevation: 5,
          margin: const EdgeInsets.all(10),
          child: Column(
            children: [
              Container(
                  width: double.infinity,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.fromLTRB(10.0, 10.0, 0, 8),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 15,
                        backgroundColor: Pallete.accentColor,
                        child: widget.user.image == null
                            ? Icon(
                                Icons.person,
                                size: 17,
                                color: Pallete.paleBlueColor,
                              )
                            : ClipOval(
                                child: Image.network(
                                  widget.user.image!,
                                  fit: BoxFit.cover,
                                  width: 30,
                                  height: 30,
                                ),
                              ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        widget.user.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Pallete.paleBlueColor,
                          decoration: _isHovering
                              ? TextDecoration.underline
                              : TextDecoration.none,
                        ),
                      ),
                    ],
                  )),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Card(
                      color: Pallete.backgroundColor,
                      elevation: 0,
                      margin: EdgeInsets.fromLTRB(8, 0, 8, 8),
                      child: Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Container(
                              width: double.infinity,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (isEditing) const SizedBox(height: 30),
                                  isEditing
                                      ? ParamTextBox(
                                          controller: titleController,
                                          text: 'Title',
                                        )
                                      : Text(
                                          widget.comment.title,
                                          style: TextStyle(
                                            color: Pallete.textColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                  const SizedBox(height: 8),
                                  isEditing
                                      ? ParamTextBox(
                                          controller: contentController,
                                          text: 'Content',
                                        )
                                      : Text(
                                          widget.comment.content,
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Pallete.textColor,
                                          ),
                                        ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      if (isEditing)
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              8, 0, 8, 0),
                                          child: Text(
                                            ratingValue.toString(),
                                            style: const TextStyle(
                                              fontSize: 18,
                                              color: Colors.amber,
                                            ),
                                          ),
                                        ),
                                      if (isEditing)
                                        RatingBar.builder(
                                          initialRating: ratingValue,
                                          allowHalfRating: true,
                                          onRatingUpdate: (rating) {
                                            setState(() {
                                              ratingValue = rating;
                                            });
                                          },
                                          itemBuilder: (context, index) =>
                                              const Icon(
                                            Icons.star,
                                            color: Colors.amber,
                                            size: 25.0,
                                          ),
                                          itemCount: 5,
                                          itemSize: 25.0,
                                          direction: Axis.horizontal,
                                          unratedColor:
                                              Colors.blueAccent.withAlpha(50),
                                        )
                                      else
                                        RatingBarIndicator(
                                          rating: ratingValue,
                                          itemBuilder: (context, index) =>
                                              const Icon(
                                            Icons.star,
                                            color: Colors.amber,
                                            size: 22.0,
                                          ),
                                          itemCount: 5,
                                          itemSize: 22.0,
                                          direction: Axis.horizontal,
                                          //allowHalfRating: true,
                                          unratedColor:
                                              Colors.blueAccent.withAlpha(50),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (widget.isOwner)
                            Positioned(
                              top: 0,
                              right: 0,
                              child: Row(
                                children: [
                                  if (isEditing)
                                    Tooltip(
                                      message: "Update",
                                      decoration: BoxDecoration(
                                        color: Colors.green.withOpacity(0.3),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: IconButton(
                                        icon: const Icon(Icons.check),
                                        iconSize: 30,
                                        color: Colors.green,
                                        onPressed: () {
                                          toggleEdit();
                                          widget.onUpdate(
                                              getComment(), widget.index);
                                        },
                                      ),
                                    ),
                                  if (isEditing)
                                    Tooltip(
                                      message: "Cancel",
                                      decoration: BoxDecoration(
                                        color: Colors.red.withOpacity(0.3),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: IconButton(
                                        icon: const Icon(Icons.cancel),
                                        iconSize: 30,
                                        color: Colors.red,
                                        onPressed: toggleEdit,
                                      ),
                                    ),
                                  if (!isEditing)
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      color: Pallete.accentColor,
                                      onPressed: toggleEdit,
                                    ),
                                  if (!isEditing)
                                    IconButton(
                                      icon: const Icon(Icons.clear),
                                      color: Pallete.salmonColor,
                                      onPressed: () {
                                        widget.onDelete(context,
                                            widget.comment.id!, widget.index);
                                      },
                                    ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

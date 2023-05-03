import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:skeletons/skeletons.dart';

class UserAvatar extends StatelessWidget {
  final String imageUrl;
  final double size;
  final bool? isLoading;
  const UserAvatar({
    super.key,
    required this.imageUrl,
    required this.size,
    required this.isLoading,
  });

  Widget _noAvatarImage(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(100),
      child: SizedBox(
        height: size,
        width: size,
        child: SizedBox(
          child: Image.asset('assets/images/default_user_image.png'),
        ),
      ),
    );
  }

  Widget _skeletonLoader(BuildContext context) {
    return SkeletonAvatar(
      style: SkeletonAvatarStyle(
        shape: BoxShape.circle,
        height: size,
        width: size,
      ),
    );
  }

  Widget _buildNetworkImage(BuildContext context) {
    if (imageUrl == '') {
      return _noAvatarImage(context);
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      placeholder: (context, url) {
        return _skeletonLoader(context);
      },
      errorWidget: (context, url, error) {
        return _noAvatarImage(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(100),
      child: FittedBox(
        fit: BoxFit.cover,
        child: isLoading == true
            ? _skeletonLoader(context)
            : _buildNetworkImage(context),
      ),
    );
  }
}

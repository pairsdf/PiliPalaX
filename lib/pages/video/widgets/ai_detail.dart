import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:PiliPalaX/models/video/ai.dart';
import 'package:PiliPalaX/pages/video/index.dart';
import 'package:PiliPalaX/utils/utils.dart';

import '../../../plugin/pl_player/controller.dart';

class AiDetail extends StatelessWidget {
  final ModelResult? modelResult;

  const AiDetail({
    super.key,
    this.modelResult,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.only(left: 14, right: 14),
      height: 500,
      width: min(Get.width, 500),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Text(
              modelResult!.summary!,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            ListView.builder(
              shrinkWrap: true,
              itemCount: modelResult!.outline!.length,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    Text(
                      modelResult!.outline![index].title!,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount:
                          modelResult!.outline![index].partOutline!.length,
                      itemBuilder: (context, i) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              children: [
                                RichText(
                                  text: TextSpan(
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onBackground,
                                      height: 1.5,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: Utils.tampToSeektime(modelResult!
                                            .outline![index]
                                            .partOutline![i]
                                            .timestamp!),
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () {
                                            // 跳转到指定位置
                                            PlPlayerController.seekToIfExists(
                                                Duration(
                                                  seconds: Utils.duration(
                                                    Utils.tampToSeektime(
                                                            modelResult!
                                                                .outline![index]
                                                                .partOutline![i]
                                                                .timestamp!)
                                                        .toString(),
                                                  ),
                                                ),
                                                type: 'slider');
                                          },
                                      ),
                                      const TextSpan(text: ' '),
                                      TextSpan(
                                          text: modelResult!.outline![index]
                                              .partOutline![i].content!),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                );
              },
            )
          ],
        ),
      ),
    );
  }

  InlineSpan buildContent(BuildContext context, content) {
    List descV2 = content.descV2;
    // type
    // 1 普通文本
    // 2 @用户
    List<TextSpan> spanChildren = List.generate(descV2.length, (index) {
      final currentDesc = descV2[index];
      switch (currentDesc.type) {
        case 1:
          List<InlineSpan> spanChildren = [];
          RegExp urlRegExp = RegExp(r'https?://\S+\b');
          Iterable<Match> matches = urlRegExp.allMatches(currentDesc.rawText);

          int previousEndIndex = 0;
          for (Match match in matches) {
            if (match.start > previousEndIndex) {
              spanChildren.add(TextSpan(
                  text: currentDesc.rawText
                      .substring(previousEndIndex, match.start)));
            }
            spanChildren.add(
              TextSpan(
                text: match.group(0),
                style: TextStyle(
                    color: Theme.of(context).colorScheme.primary), // 设置颜色为蓝色
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    // 处理点击事件
                    try {
                      Get.toNamed(
                        '/webview',
                        parameters: {
                          'url': match.group(0)!,
                          'type': 'url',
                          'pageTitle': match.group(0)!,
                        },
                      );
                    } catch (err) {
                      SmartDialog.showToast(err.toString());
                    }
                  },
              ),
            );
            previousEndIndex = match.end;
          }

          if (previousEndIndex < currentDesc.rawText.length) {
            spanChildren.add(TextSpan(
                text: currentDesc.rawText.substring(previousEndIndex)));
          }

          TextSpan result = TextSpan(children: spanChildren);
          return result;
        case 2:
          final colorSchemePrimary = Theme.of(context).colorScheme.primary;
          final heroTag = Utils.makeHeroTag(currentDesc.bizId);
          return TextSpan(
            text: '@${currentDesc.rawText}',
            style: TextStyle(color: colorSchemePrimary),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                Get.toNamed(
                  '/member?mid=${currentDesc.bizId}',
                  arguments: {'face': '', 'heroTag': heroTag},
                );
              },
          );
        default:
          return const TextSpan();
      }
    });
    return TextSpan(children: spanChildren);
  }
}

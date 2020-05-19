// To parse this JSON data, do
//
//     final interactiveNewModel = interactiveNewModelFromJson(jsonString);

import 'dart:convert';

InteractiveNewModel interactiveNewModelFromJson(String str) => InteractiveNewModel.fromJson(json.decode(str));

String interactiveNewModelToJson(InteractiveNewModel data) => json.encode(data.toJson());

class InteractiveNewModel {
    String id;
    List<Block> blocks;
    Answers answers;
    List<Asset> assets;
    int number;
    String lessonId;

    InteractiveNewModel({
        this.id,
        this.blocks,
        this.answers,
        this.assets,
        this.number,
        this.lessonId,
    });

    factory InteractiveNewModel.fromJson(Map<String, dynamic> json) {

      List<Asset> data = new List<Asset>();
      if (json["assets"] != null) {
        json["assets"].forEach((a, b) {
          data.add(Asset(name: a.toString(), url: b.toString()));
        });
      }

      return InteractiveNewModel(
        id: json["id"] == null ? null : json["id"],
        blocks: json["blocks"] == null ? null : List<Block>.from(json["blocks"].map((x) => Block.fromJson(x))),
        answers: json["answers"] == null ? null : Answers.fromJson(json["answers"]),
        assets: data,
        number: json["number"] == null ? null : json["number"],
        lessonId: json["lesson_id"] == null ? null : json["lesson_id"],
      );
    }

    Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "blocks": blocks == null ? null : List<dynamic>.from(blocks.map((x) => x.toJson())),
        "answers": answers == null ? null : answers.toJson(),
        // "assets": assets == null ? null : assets.toJson(),
        "number": number == null ? null : number,
        "lesson_id": lessonId == null ? null : lessonId,
    };
}

class Answers {
    Answers();

    factory Answers.fromJson(Map<String, dynamic> json) => Answers(
    );

    Map<String, dynamic> toJson() => {
    };
}

class Asset {
  String name;
  String url;

  Asset({
    this.name,
    this.url
  });
}

class Block {
    String type;
    Content content;

    Block({
        this.type,
        this.content,
    });

    factory Block.fromJson(Map<String, dynamic> json) => Block(
        type: json["type"] == null ? null : json["type"],
        content: json["content"] == null ? null : Content.fromJson(json["content"]),
    );

    Map<String, dynamic> toJson() => {
        "type": type == null ? null : type,
        "content": content == null ? null : content.toJson(),
    };
}

class Content {
    String text;
    List<Interactive> interactive;

    Content({
        this.text,
        this.interactive,
    });

    factory Content.fromJson(Map<String, dynamic> json) => Content(
        text: json["text"] == null ? null : json["text"],
        interactive: json["interactive"] == null ? null : List<Interactive>.from(json["interactive"].map((x) => Interactive.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "text": text == null ? null : text,
        "interactive": interactive == null ? null : List<dynamic>.from(interactive.map((x) => x.toJson())),
    };
}

class Interactive {
    String key;
    String name;
    String state;
    List<Hotspot> hotspots;
    String nextObj;

    Interactive({
        this.key,
        this.name,
        this.state,
        this.hotspots,
        this.nextObj,
    });

    factory Interactive.fromJson(Map<String, dynamic> json) => Interactive(
        key: json["key"] == null ? null : json["key"],
        name: json["name"] == null ? null : json["name"],
        state: json["state"] == null ? null : json["state"],
        hotspots: json["hotspots"] == null ? null : List<Hotspot>.from(json["hotspots"].map((x) => Hotspot.fromJson(x))),
        nextObj: json["next_obj"] == null ? null : json["next_obj"],
    );

    Map<String, dynamic> toJson() => {
        "key": key == null ? null : key,
        "name": name == null ? null : name,
        "state": state == null ? null : state,
        "hotspots": hotspots == null ? null : List<dynamic>.from(hotspots.map((x) => x.toJson())),
        "next_obj": nextObj == null ? null : nextObj,
    };
}

class Hotspot {
    double top;
    double left;
    String name;
    double width;
    double height;
    String nextObj;
    double milisecond;

    Hotspot({
        this.top,
        this.left,
        this.name,
        this.width,
        this.height,
        this.nextObj,
        this.milisecond,
    });

    factory Hotspot.fromJson(Map<String, dynamic> json) => Hotspot(
        top: json["top"] == null ? null : json["top"].toDouble(),
        left: json["left"] == null ? null : json["left"].toDouble(),
        name: json["name"] == null ? null : json["name"],
        width: json["width"] == null ? null : json["width"].toDouble(),
        height: json["height"] == null ? null : json["height"].toDouble(),
        nextObj: json["next_obj"] == null ? null : json["next_obj"],
        milisecond: json["milisecond"] == null ? null : json["milisecond"].toDouble(),
    );

    Map<String, dynamic> toJson() => {
        "top": top == null ? null : top,
        "left": left == null ? null : left,
        "name": name == null ? null : name,
        "width": width == null ? null : width,
        "height": height == null ? null : height,
        "next_obj": nextObj == null ? null : nextObj,
        "milisecond": milisecond == null ? null : milisecond,
    };
}

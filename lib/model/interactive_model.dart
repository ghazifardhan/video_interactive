// To parse this JSON data, do
//
//     final videoInteractive = videoInteractiveFromJson(jsonString);

import 'dart:convert';

import 'package:flutter/material.dart';

InteractiveModel videoInteractiveFromJson(String str) => InteractiveModel.fromJson(json.decode(str));

String videoInteractiveToJson(InteractiveModel data) => json.encode(data.toJson());

class InteractiveModel {
  List<Datum> data;

  InteractiveModel({
    this.data,
  });

  factory InteractiveModel.fromJson(Map<String, dynamic> json) => InteractiveModel(
    data: json["data"] == null ? null : List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "data": data == null ? null : List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class Datum {
  GlobalKey key;
  String url;
  String asset;
  bool hotspot;
  List<Area> area;
  int nextVideos;

  Datum({
    this.key,
    this.url,
    this.asset,
    this.hotspot,
    this.area,
    this.nextVideos,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    key: json["key"] == null ? GlobalKey() : json["key"],
    url: json["url"] == null ? null : json["url"],
    asset: json["asset"] == null ? null : json["asset"],
    hotspot: json["hotspot"] == null ? null : json["hotspot"],
    area: json["area"] == null ? null : List<Area>.from(json["area"].map((x) => Area.fromJson(x))),
    nextVideos: json["next_videos"] == null ? null : json["next_videos"],
  );

  Map<String, dynamic> toJson() => {
    "key": key == null ? null : key,
    "url": url == null ? null : url,
    "asset": asset == null ? null : asset,
    "hotspot": hotspot == null ? null : hotspot,
    "area": area == null ? null : List<dynamic>.from(area.map((x) => x.toJson())),
    "next_videos": nextVideos == null ? null : nextVideos,
  };
}

class Area {
  double x;
  double y;
  double height;
  double width;
  double borderRadius;
  int nextVideos;

  Area({
    this.x,
    this.y,
    this.height,
    this.width,
    this.borderRadius,
    this.nextVideos,
  });

  factory Area.fromJson(Map<String, dynamic> json) => Area(
    x: json["x"] == null ? null : json["x"].toDouble(),
    y: json["y"] == null ? null : json["y"].toDouble(),
    height: json["height"] == null ? null : json["height"].toDouble(),
    width: json["width"] == null ? null : json["width"].toDouble(),
    borderRadius: json["border_radius"] == null ? null : json["border_radius"].toDouble(),
    nextVideos: json["next_videos"] == null ? null : json["next_videos"],
  );

  Map<String, dynamic> toJson() => {
    "x": x == null ? null : x,
    "y": y == null ? null : y,
    "height": height == null ? null : height,
    "width": width == null ? null : width,
    "border_radius": borderRadius == null ? null : borderRadius,
    "next_videos": nextVideos == null ? null : nextVideos,
  };
}

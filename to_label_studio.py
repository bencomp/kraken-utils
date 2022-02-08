"""Convert Page XML to Label Studio JSON"""
import xml.etree.ElementTree as ET
import sys
from typing import Tuple, Optional, Dict
import itertools


NS = {'page': 'http://schema.primaresearch.org/PAGE/gts/pagecontent/2019-07-15'}


def convert_from_ls(result: Dict) -> Optional[Tuple[float, float, float, float]]:
    if 'original_width' not in result or 'original_height' not in result:
        return None

    value = result['value']
    w, h = result['original_width'], result['original_height']

    if all([key in value for key in ['x', 'y', 'width', 'height']]):
        return w * value['x'] / 100.0, \
               h * value['y'] / 100.0, \
               w * value['width'] / 100.0, \
               h * value['height'] / 100.0


def convert_to_ls(x, y, width, height, original_width, original_height):
    """convert from pixels to LS percent units"""
    return x / original_width * 100.0, y / original_height * 100.0, \
           width / original_width * 100.0, height / original_height * 100

def convert_point_to_ls(x, y, original_width, original_height):
    """convert from pixels to LS percent units"""
    return [x / original_width * 100.0, y / original_height * 100.0]

def convert_points(points, original_width, original_height):
    for point in points:
        x0, y0 = point.split(",")
        yield convert_point_to_ls(x0, y0, original_width, original_height)

def close_polygon(points):
    points_out = points + [points[0]]
    return [k for k, g in itertools.groupby(points_out)]

def create_prediction(pred_num, task_id, text, pw, ph, points):
    converted_points = [point for point in convert_points(points, pw, ph)]
    return {
            "id": pred_num,
            "result":[
               {
                  "original_width": pw,
                  "original_height": ph,
                  "image_rotation":0,
                  "value":{
                    "points": converted_points,
                    "polygonlabels": ["Line"]
                  },
                  "id":f"id_{pred_num}",
                  "from_name":"label",
                  "to_name":"image",
                  "type":"polygonlabels"
                },
                {
                  "original_width": pw,
                  "original_height": ph,
                  "image_rotation":0,
                  "value":{
                    "points": converted_points,
                    "text": [text]
                  },
                  "id":f"id_{pred_num}",
                  "from_name":"answer",
                  "to_name":"image",
                  "type":"textarea"
                }
            ],
            "task": task_id
        }


def create_task(image, lines, pw, ph):
    task = {"id": 1}
    task["data"] = {"image": image}
    for line_nr, line in enumerate(lines):
        text = "FIXME"
        points = ["FIXME"]
        pred = create_prediction(line_nr, 1, text, pw, ph, points)

def main():
    with open(sys.argv[1], encoding='utf-8') as xml_file:
        xml_contents = ET.parse(xml_file)
    page = xml_contents.find("page:Page", NS)
    page_width = page.attrib["imageWidth"]
    page_height = page.attrib["imageHeight"]
    for coords_list in xml_contents.findall("//page:Coords[@points]", NS):
        print(coords_list.attrib['points'])
        print('-->', " ".join(close_polygon(coords_list.attrib['points'].split())))
    # print(xml_contents.getroot().tag)


if __name__ == "__main__":
    main()

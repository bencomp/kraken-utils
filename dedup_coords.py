"""Remove repeated points from Coords in Page XML"""
import xml.etree.ElementTree as ET
import sys
from typing import List
import itertools
import datetime


NS = {'page': 'http://schema.primaresearch.org/PAGE/gts/pagecontent/2019-07-15'}


def dedup_coords(points: List[str]) -> List[str]:
    """Remove repeated points from a list"""
    return [k for k, g in itertools.groupby(points)]


def main():
    with open(sys.argv[1], encoding='utf-8') as xml_file:
        xml_contents = ET.parse(xml_file)
    page = xml_contents.find("page:Page", NS)
    page_width = page.attrib["imageWidth"]
    page_height = page.attrib["imageHeight"]
    for coords_list in xml_contents.findall(".//page:Coords[@points]", NS):
        new_coords = dedup_coords(coords_list.attrib['points'].split())
        coords_list.attrib['points'] = ' '.join(new_coords)
    ET.register_namespace('', 'http://schema.primaresearch.org/PAGE/gts/pagecontent/2019-07-15')
    xml_contents.find(".//page:LastChange", NS).text = datetime.datetime.now(datetime.timezone.utc).isoformat()
    xml_contents.write(sys.argv[2], encoding='utf-8', xml_declaration=True)


if __name__ == "__main__":
    main()

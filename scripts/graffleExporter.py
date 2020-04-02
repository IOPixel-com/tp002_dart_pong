#!//usr/bin/env python3
import argparse
import gzip
import plistlib
import re
import os.path
import json


def parse2Elements(text):
    """Parse a rectangle and its metadata"""
    regex = re.compile("{(.*), (.*)}")
    res = regex.search(text)
    try:
        x = float(res.group(1))
        y = float(res.group(2))
    except:
        raise NameError("Parsing error")
    return [x, y]


def parseBounds(graphicElement):
    bounds = graphicElement['Bounds']
    regex = re.compile("{{(.*), (.*)}, {(.*), (.*)}}")
    res = regex.search(bounds)
    try:
        x = float(res.group(1))
        y = float(res.group(2))
        width = float(res.group(3))
        height = float(res.group(4))
    except:
        raise Exception("Parsing error")
    return [x + width / 2, y + height / 2, width, height]
# Shape


class OmnigraffleLoader():

    def loadImages(self, res, plist):
        res['images'] = {}
        if 'Images' in plist:
            for img in plist['Images']:
                uid = img['ID']
                spriteName = os.path.basename(img['FileReference']['path'])
                res['images'][uid] = spriteName
            #msg = "uid: %s uid: %s" % (uid, res['images'][uid])
            # print(msg)

    def loadGraphics(self, res, plist):
        zOrder = 0
        res['objects'] = {}
        if 'Sheets' not in plist:
            return
        links = []
        for sheet in plist['Sheets']:
            # canvas size
            size = parse2Elements(sheet['CanvasSize'])
            res['canvas_size'] = size
            for g in sheet['GraphicsList']:
                if 'Class' in g and g['Class'] == 'LineGraphic':
                    fromLink = g['Head']
                    toLink = g['Tail']
                    links.append({'parent': toLink, 'child': fromLink})
            graphicElements = sheet['GraphicsList']
            graphicElements.reverse()
            for g in graphicElements:
                # skip links
                if 'Class' in g and g['Class'] == 'LineGraphic':
                    continue
                if not 'UserInfo' in g:
                    print('Warning invalid shape', g)
                    continue
                # default info
                shape = {'shape': 'Rectangle'}
                shape['ID'] = g['ID']
                shape['name'] = g['Name']
                # read user info
                userInfo = g['UserInfo']
                shape['align'] = userInfo['align']
                shape['valign'] = userInfo['valign']
                shape['category'] = userInfo['category']
                shape['scale'] = userInfo['scale']
                if 'widget' in userInfo:
                    shape['widget'] = userInfo['widget']
                if 'align' in userInfo:
                    shape['align']
                if 'Shape' in g:
                    shape['shape'] = g['Shape']
                if shape['shape'] == 'Circle' or shape['shape'] == 'Rectangle':
                    bounds = parseBounds(g)
                    shape['size'] = [bounds[2], bounds[3]]
                    shape['center'] = [bounds[0], bounds[1]]
                if 'ImageID' in g:
                    shape['sprite'] = res['images'][g['ImageID']]
                shape['children'] = []
                res['objects'][shape['ID']] = shape
                shape['z_order'] = zOrder
                zOrder += 1
            # recreate links
            for link in links:
                parentID = link['parent']['ID']
                childID = link['child']['ID']
                parent = res['objects'][parentID]
                child = res['objects'][childID]
                parent['children'].append(child)
                # fix child position
                # posX = child['center'][0] - parent['center'][0]
                # posY = child['center'][1] - parent['center'][1]
                child['center'] = [child['center'][0], child['center'][1]]
                child['parentID'] = parentID

    def openGzipOmnigraffle(self, filepath):
        res = {}
        '''Open a gzip file'''
        f = gzip.open(filepath, 'r')
        content = f.read()
        p = plistlib.loads(content)
        # check version
        if p['ApplicationVersion'][0] != 'com.omnigroup.OmniGraffle7':
            raise Exception("Incompatible Omnigraffle (%s) Only com.omnigroup.OmniGraffle7 supported" %
                            p['ApplicationVersion'][0])
        # load images
        self.loadImages(res, p)
        # load shapes
        self.loadGraphics(res, p)
        # transform
        output = {}
        output['elements'] = []
        output['size'] = res['canvas_size']
        for v in res['objects'].values():
            if 'parentID' in v:
                continue
            output['elements'].append(v)
        output['elements'].sort(key=lambda el: el['z_order'])
        # export to file
        bn = os.path.basename(filepath)
        filename = os.path.splitext(bn)[0]
        filepath = 'assets/%s.json' % filename
        f = open(filepath, 'w')
        json.dump(output, f)
        f.close()


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Parser for Omnigraffle')
    parser.add_argument('infile', nargs=1, help='name of omnigraffle file')
    args = parser.parse_args()
    loader = OmnigraffleLoader()
    loader.openGzipOmnigraffle(args.infile[0])

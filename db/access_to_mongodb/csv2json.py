#!/usr/bin/python
"""
A simple script for generating JSON/JavaScript from comma-separated (or
otherwise delimited) values.

by Shawn Allen <shawn at stamen dot com>
"""
import csv, simplejson, codecs, cStringIO
from StringIO import StringIO

# These are shorthands for delimiters that might be a pain to type or escape.
delimiter_map = {'tab': '\t',
                 'sc':  ';',
                 'bar': '|'}
class UTF8Recoder:
    """
    Iterator that reads an encoded stream and reencodes the input to UTF-8
    """
    def __init__(self, f, encoding):
        self.reader = codecs.getreader(encoding)(f)

    def __iter__(self):
        return self

    def next(self):
        return self.reader.next().encode("utf-8")

class UnicodeReader:
    """
    A CSV reader which will iterate over lines in the CSV file "f",
    which is encoded in the given encoding.
    """

    def __init__(self, f, dialect=csv.excel, encoding="utf-8", **kwds):
        f = UTF8Recoder(f, encoding)
        self.reader = csv.reader(f, dialect=dialect, **kwds)

    def next(self):
        row = self.reader.next()
        return [unicode(s, "utf-8") for s in row]

    def __iter__(self):
        return self

class UnicodeWriter:
    """
    A CSV writer which will write rows to CSV file "f",
    which is encoded in the given encoding.
    """

    def __init__(self, f, dialect=csv.excel, encoding="utf-8", **kwds):
        # Redirect output to a queue
        self.queue = cStringIO.StringIO()
        self.writer = csv.writer(self.queue, dialect=dialect, **kwds)
        self.stream = f
        self.encoder = codecs.getincrementalencoder(encoding)()

    def writerow(self, row):
        self.writer.writerow([s.encode("utf-8") for s in row])
        # Fetch UTF-8 output from the queue ...
        data = self.queue.getvalue()
        data = data.decode("utf-8")
        # ... and reencode it into the target encoding
        data = self.encoder.encode(data)
        # write to the target stream
        self.stream.write(data)
        # empty queue
        self.queue.truncate(0)

    def writerows(self, rows):
        for row in rows:
            self.writerow(row)

def unicode_csv_reader(unicode_csv_data, dialect=csv.excel, **kwargs):
    # csv.py doesn't do Unicode; encode temporarily as UTF-8:
    csv_reader = csv.reader(utf_8_encoder(unicode_csv_data),
                            dialect=dialect, **kwargs)
    for row in csv_reader:
        # decode UTF-8 back to Unicode, cell by cell:
        yield [unicode(cell, 'utf-8') for cell in row]

def utf_8_encoder(unicode_csv_data):
    for line in unicode_csv_data:
        yield line.encode('utf-8')

def csv2json(csv_file, delimiter=',', quotechar='"', indent=None, callback=None, variable=None, **csv_opts):
    if delimiter_map.has_key(delimiter):
        delimiter = delimiter_map.get(delimiter)
    reader = csv.DictReader(csv_file, delimiter=delimiter, quotechar=quotechar or None, **csv_opts)
    rows = [row for row in reader]
    if hasattr(indent, 'isdigit') and indent.isdigit():
        indent = ' ' * int(indent)
    out = StringIO()
    if callback:
        out.write('%s(' % callback);
    elif variable:
        out.write('var %s = ' % variable)
    simplejson.dump(rows, out, indent=indent)
    if callback:
        out.write(');');
    elif variable:
        out.write(';')
    return out.getvalue()

if __name__ == '__main__':
    import sys
    from optparse import OptionParser

    parser = OptionParser()
    parser.add_option('-F', '--field-separator', dest='fs', default=',',
                      help='The CSV file field separator, default: %default')
    parser.add_option('-q', '--field-quote', dest='fq', default='"',
                      help='The CSV file field quote character, default: %default')
    parser.add_option('-i', '--indent', dest='indent', default=None,
                      help='The string with which to indent the output GeoJSON, '
                           'defaults to none.')
    parser.add_option('-p', '--callback', dest='callback', default=None,
                      help='The JSON-P callback function name.')
    parser.add_option('-v', '--variable', dest='var', default=None,
                      help='If provided, the output becomes a JavaScript statement'
                      ' which assigns the JSON structure to a variable of the same'
                      ' name.')
    options, args = parser.parse_args()

    close = False
    if len(args) > 0 and args[0] != '-':
        csv_file = open(args.pop(0), 'r')
        close = True
    else:
        csv_file = sys.stdin
    print csv2json(csv_file, options.fs, options.fq, options.indent, options.callback, options.var)
    if close:
        csv_file.close()


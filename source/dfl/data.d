// Written by Christopher E. Miller
// See the included license.txt for copyright and license details.


///
module dfl.data;

private import dfl.base;
private import dfl.application;
private import dfl.drawing;

private import dfl.internal.dlib;
private import dfl.internal.utf;
private import dfl.internal.com;
private import dfl.internal.winapi;
private import dfl.internal.wincom;

private import core.sys.windows.ole2;
import core.sys.windows.richedit;


///
final class DataFormats
{
	///
	static class Format
	{
		/// Data format ID number.
		@property int id() // getter
		{
			return _id;
		}
		
		
		/// Data format name.
		@property Dstring name() // getter
		{
			return _name;
		}
		
		
		this(int id, Dstring name)
		{
			_id = id;
			_name = name;
		}

	private:
		int _id;
		Dstring _name;
	}
	
	
static:
	
	/// Predefined data formats.
	@property Dstring bitmap() // getter
	{
		return getFormat(CF_BITMAP).name;
	}
	
	/+
	/// ditto
	@property Dstring commaSeparatedValue() // getter
	{
		return getFormat(?).name;
	}
	+/
	
	/// ditto
	@property Dstring dib() // getter
	{
		return getFormat(CF_DIB).name;
	}
	
	/// ditto
	@property Dstring dibv5() // getter
	{
		return getFormat(CF_DIBV5).name;
	}

	/// ditto
	@property Dstring dif() // getter
	{
		return getFormat(CF_DIF).name;
	}
	
	/// ditto
	@property Dstring enhandedMetaFile() // getter
	{
		return getFormat(CF_ENHMETAFILE).name;
	}
	
	/// ditto
	@property Dstring fileDrop() // getter
	{
		return getFormat(CF_HDROP).name;
	}
	
	/// ditto
	@property Dstring html() // getter
	{
		return getFormat("HTML Format").name;
	}
	
	/// ditto
	@property Dstring locale() // getter
	{
		return getFormat(CF_LOCALE).name;
	}
	
	/// ditto
	@property Dstring metafilePict() // getter
	{
		return getFormat(CF_METAFILEPICT).name;
	}
	
	/// ditto
	@property Dstring oemText() // getter
	{
		return getFormat(CF_OEMTEXT).name;
	}
	
	/// ditto
	@property Dstring palette() // getter
	{
		return getFormat(CF_PALETTE).name;
	}
	
	/// ditto
	@property Dstring penData() // getter
	{
		return getFormat(CF_PENDATA).name;
	}
	
	/// ditto
	@property Dstring riff() // getter
	{
		return getFormat(CF_RIFF).name;
	}
	
	/// ditto
	@property Dstring rtf() // getter
	{
		return getFormat("Rich Text Format").name;
	}
	
	/+
	/// ditto
	@property Dstring serializable() // getter
	{
		return getFormat(?).name;
	}
	+/
	
	/// ditto
	@property Dstring stringFormat() // getter
	{
		return utf8;
	}
	
	/// ditto
	@property Dstring utf8() // getter
	{
		return getFormat("UTF-8").name;
	}
	
	/// ditto
	@property Dstring symbolicLink() // getter
	{
		return getFormat(CF_SYLK).name;
	}
	
	/// ditto
	@property Dstring text() // getter
	{
		return getFormat(CF_TEXT).name;
	}
	
	/// ditto
	@property Dstring tiff() // getter
	{
		return getFormat(CF_TIFF).name;
	}
	
	/// ditto
	@property Dstring unicodeText() // getter
	{
		return getFormat(CF_UNICODETEXT).name;
	}
	
	/// ditto
	@property Dstring waveAudio() // getter
	{
		return getFormat(CF_WAVE).name;
	}
	
	
	// Assumes _init() was already called and
	// -id- is not in -fmts-.
	private Format _didntFindId(int id)
	{
		Format result = new Format(id, getName(id));
		//synchronized // _init() would need to be synchronized with it.
		{
			_fmts[id] = result;
		}
		return result;
	}
	
	
	///
	Format getFormat(int id)
	{
		_init();
		
		if(id in _fmts)
			return _fmts[id];
		
		return _didntFindId(id);
	}
	
	/// ditto
	// Creates the format name if it doesn't exist.
	Format getFormat(Dstring name)
	{
		_init();
		foreach(Format onfmt; _fmts)
		{
			if(!stringICmp(name, onfmt.name))
				return onfmt;
		}
		// Didn't find it.
		return _didntFindId(dfl.internal.utf.registerClipboardFormat(name));
	}
	
	/// ditto
	// Extra.
	Format getFormat(TypeInfo type)
	{
		return getFormatFromType(type);
	}
	
	
private:
	Format[int] _fmts; // Indexed by identifier. Must _init() before accessing!
	
	
	///
	void _init()
	{
		if(_fmts.length)
			return;
		
		void appendFormat(int id, Dstring name)
		in
		{
			assert(!(id in _fmts));
		}
		do
		{
			Format fmt = new Format(id, name);
			_fmts[id] = fmt;
		}
		
		// https://learn.microsoft.com/en-us/dotnet/api/system.windows.dataformats?view=netframework-4.8
		appendFormat(CF_BITMAP, "Bitmap");
		appendFormat(CF_DIB, "DeviceIndependentBitmap");
		appendFormat(CF_DIF, "DataInterchangeFormat");
		appendFormat(CF_ENHMETAFILE, "EnhancedMetafile");
		appendFormat(CF_HDROP, "FileDrop");
		appendFormat(CF_LOCALE, "Locale");
		appendFormat(CF_METAFILEPICT, "MetaFilePict");
		appendFormat(CF_OEMTEXT, "OEMText");
		appendFormat(CF_PALETTE, "Palette");
		appendFormat(CF_PENDATA, "PenData");
		appendFormat(CF_RIFF, "RiffAudio");
		appendFormat(CF_SYLK, "SymbolicLink");
		appendFormat(CF_TEXT, "Text");
		appendFormat(CF_TIFF, "TaggedImageFileFormat");
		appendFormat(CF_UNICODETEXT, "UnicodeText");
		appendFormat(CF_WAVE, "WaveAudio");
		appendFormat(CF_DIBV5, "DeviceIndependentBitmapV5");
		
		_fmts.rehash;
	}
	
	
	/// Does not get the name of one of the predefined constant ones.
	Dstring getName(int id)
	{
		Dstring result = dfl.internal.utf.getClipboardFormatName(id);
		if(!result)
		{
			// You must call appendFormat() for other Standard Clipboard Formats.
			// https://learn.microsoft.com/en-us/windows/win32/dataxchg/standard-clipboard-formats
			throw new DflException("Unable to get format");
		}
		return result;
	}
	
	
	///
	package Format getFormatFromType(TypeInfo type)
	{
		if(type == typeid(ubyte[]))
			return getFormat(text);
		if(type == typeid(Dstring))
			return getFormat(stringFormat);
		if(type == typeid(Dwstring))
			return getFormat(unicodeText);
		if(type == typeid(Image) || type == typeid(Bitmap)) // TODO: ?
			return getFormat(bitmap);
		
		if(cast(TypeInfo_Class)type)
			throw new DflException("Unknown data format");
		
		return getFormat(getObjectString(type)); // TODO: ?
	}
	
	
	///
	Dstring[] getHDropStrings(void[] value)
	{
		if(value.length <= DROPFILES.sizeof)
			return null;
		
		Dstring[] result;
		size_t iw, startiw;
		
		DROPFILES* df = cast(DROPFILES*)value.ptr;
		if(df.pFiles < DROPFILES.sizeof || df.pFiles >= value.length)
			return null;
		
		if(df.fWide) // Unicode.
		{
			Dwstring uni = cast(Dwstring)((value.ptr + df.pFiles)[0 .. value.length]);
			for(iw = startiw = 0;; iw++)
			{
				if(!uni[iw])
				{
					if(startiw == iw)
						break;
					result ~= fromUnicode(uni.ptr + startiw, iw - startiw);
					assert(result[$ - 1].length);
					startiw = iw + 1;
				}
			}
		}
		else // ANSI.
		{
			Dstring ansi = cast(Dstring)((value.ptr + df.pFiles)[0 .. value.length]);
			for(iw = startiw = 0;; iw++)
			{
				if(!ansi[iw])
				{
					if(startiw == iw)
						break;
					result ~= fromAnsi(ansi.ptr + startiw, iw - startiw);
					assert(result[$ - 1].length);
					startiw = iw + 1;
				}
			}
		}
		
		return result;
	}
	
	
	// Converts clipboard -value- to Data.
	Data getDataFromFormat(int id, void[] value)
	{
		switch (id)
		{
		case CF_TEXT:
			return new Data(stopAtNull!(ubyte)(cast(ubyte[])value));
		
		case CF_UNICODETEXT:
			return new Data(stopAtNull!(Dwchar)(cast(Dwstring)value));
		
		case CF_HDROP:
			return new Data(getHDropStrings(value));
		
		default:
			if(id == getFormat(stringFormat).id)
				return new Data(stopAtNull!(Dchar)(cast(Dstring)value));
			else
				throw new DflException("Unknown data format");
		}
	}
	
	
	void[] getCbFileDrop(Dstring[] fileNames)
	{
		size_t sz = DROPFILES.sizeof;
		foreach(fn; fileNames)
		{
			sz += (dfl.internal.utf.toUnicodeLength(fn) + 1) << 1;
		}
		sz += 2;
		
		void* p = (new byte[sz]).ptr;
		DROPFILES* df = cast(DROPFILES*)p;
		df.pFiles = DROPFILES.sizeof;
		df.fWide = TRUE;
		
		wchar* ws = cast(wchar*)(p + DROPFILES.sizeof);
		foreach(fn; fileNames)
		{
			foreach(wchar wch; fn)
			{
				*ws++ = wch;
			}
			*ws++ = 0;
		}
		*ws++ = 0;
		
		return p[0 .. sz];
	}
	unittest
	{
		import std.stdio;
		Dstring[] strs;
		strs ~= "aa";
		strs ~= "bb";
		strs ~= "cc";
		auto dataFormats = new DataFormats();
		void[] voids = dataFormats.getCbFileDrop(strs);
		wchar* wcharBinary = cast(wchar*)(voids);
		debug(APP_PRINT)
		{
			writefln("a part of wcharBinary's length=%d", wcharBinary[0]);
		}
		wstring wstr = wcharBinary[0 .. wcharBinary[0]].idup;
		debug(APP_PRINT)
		{
			writefln("wchar[] length=%d", wstr.length);
		}
		assert(wcharBinary[0] == wstr.length);
		debug(APP_PRINT)
		{
			for(int i; i < wcharBinary[0]; i++)
				debug(APP_PRINT) writef("'%c',", wcharBinary[i]);
			writeln();
			writefln("%s", cast(wchar[])voids);
			for(int i; i < wcharBinary[0]; i++)
				writefln("%d code:%d [%s]", i, wcharBinary[i], wcharBinary[i]);
		}
		assert(wcharBinary[0] == 20); // a part of wchar binary's length
		assert(wcharBinary[10] == 'a');
		assert(wcharBinary[11] == 'a');
		assert(wcharBinary[12] == '\0');
		assert(wcharBinary[13] == 'b');
		assert(wcharBinary[14] == 'b');
		assert(wcharBinary[15] == '\0');
		assert(wcharBinary[16] == 'c');
		assert(wcharBinary[17] == 'c');
		assert(wcharBinary[18] == '\0');
		assert(wcharBinary[19] == '\0');
	}
	
	// Value the clipboard wants.
	void[] getClipboardValueFromData(int id, Data data)
	{
		if(CF_TEXT == id)
		{
			// ANSI text.
			enum ubyte[] UBYTE_ZERO = [0];
			return data.getText() ~ UBYTE_ZERO;
		}
		else if((getFormat(stringFormat).id == id) || (data.info == typeid(Dstring)))
		{
			// UTF-8 string.
			Dstring str;
			str = data.getString() ~ '\0';
			return cast(void[])(unsafeStringz(str)[0 .. str.length]);
		}
		else if((CF_UNICODETEXT == id) || (data.info == typeid(Dwstring)))
		{
			// Unicode string.
			return (data.getUnicodeText() ~ '\0').dup;
		}
		else if(data.info == typeid(Ddstring))
		{
			return (data.getDdstring() ~ '\0').dup;
		}
		else if(CF_HDROP == id)
		{
			return getCbFileDrop(data.getFileDropList());
		}
		else if(data.info == typeid(byte[]))
		{
			return data.getBytes();
		}
		else
		{
			throw new DflException("DFL: getClipboardValueFromData failure.");
		}
	}
}


///
private template stopAtNull(T)
{
	T[] stopAtNull(T[] array)
	{
		for(size_t i = 0; i != array.length; i++)
		{
			if(!array[i])
				return array[0 .. i];
		}
		throw new DflException("Invalid data"); // TODO: ?
	}
}


/// Data class for holding data in a raw format with type information.
class Data
{
	/// Construct a new Data class.
	this(T)(T arg)
	{
		this._info = typeid(arg);
		static if (is(T == Object))
		{
			this._innerValues.objectValue = arg;
		}
		else static if (is(T == Dstring))
		{
			this._innerValues.dstringValue = arg.dup;
		}
		else static if (is(T == Dstring[]))
		{
			this._innerValues.fileDropListValue = arg.dup;
		}
		else static if (is(T == Ddstring))
		{
			this._innerValues.ddstringValue = arg.dup;
		}
		else static if (is(T == Dwstring))
		{
			this._innerValues.dwstringValue = arg.dup;
		}
		else static if (is(T == uint))
		{
			this._innerValues.uintValue = arg;
		}
		else static if (is(T == int))
		{
			this._innerValues.intValue = arg;
		}
		else static if (is(T == byte))
		{
			this._innerValues.byteValue = arg;
		}
		else static if (is(T == byte[]))
		{
			this._innerValues.bytesValue = arg.dup;
		}
		else static if (is(T == ubyte[]))
		{
			this._innerValues.ubytesValue = arg.dup;
		}
		else static if (is(T == Image))
		{
			this._innerValues.imageValue = arg;
		}
		else static if (is(T == dfl.data.IDataObject))
		{
			this._innerValues.iDataObjectValue = arg;
		}
		else static if (is(T == Data))
		{
			Data data = arg;
			this._info = data._info;
			this._innerValues = data._innerValues;
		}
		else static if (is(T == _DataConvert))
		{
			throw new DflException("DFL: class Data construct error with _DataConvert.");
		}
		else
		{
			throw new DflException("DFL: class Data construct error with unkown type.");
		}
	}
	
	
	/// Information about the data type.
	@property TypeInfo info() // getter
	{
		return _info;
	}

	
	/// Get an inner value that is Data class holded with selected type.
	// Data.
	Data getData()
	{
		assert(_info == typeid(_DataConvert));
		return _innerValues.dataValue;
	}
	

	/// ditto
	// IDataObject.
	IDataObject getIDataObject()
	{
		assert(_info == typeid(IDataObject));
		return _innerValues.iDataObjectValue;
	}

	/// ditto
	// UTF-8.
	Dstring getString()
	{
		assert(_info == typeid(Dstring));
		return _innerValues.dstringValue;
	}
	
	/// ditto
	alias getUtf8 = getString;
	/// ditto
	deprecated alias getUTF8 = getString;
	
	/// ditto
	// ANSI text.
	ubyte[] getText()
	{
		assert(_info == typeid(ubyte[]));
		return _innerValues.ubytesValue;
	}
	
	/// ditto
	Dwstring getUnicodeText()
	{
		assert(_info == typeid(Dwstring));
		return _innerValues.dwstringValue;
	}
	
	/// ditto
	Ddstring getDdstring()
	{
		assert(_info == typeid(Ddstring));
		return _innerValues.ddstringValue;
	}

	/// ditto
	int getInt()
	{
		assert(_info == typeid(int));
		return _innerValues.intValue;
	}
	
	/// ditto
	uint getUint()
	{
		assert(_info == typeid(uint));
		return _innerValues.uintValue;
	}
	
	/// ditto
	byte getByte()
	{
		assert(_info == typeid(byte));
		return _innerValues.byteValue;
	}

	/// ditto
	byte[] getBytes()
	{
		assert(_info == typeid(byte[]));
		return _innerValues.bytesValue;
	}

	/// ditto
	Dstring[] getFileDropList()
	{
		assert(_info == typeid(Dstring[]));
		return _innerValues.fileDropListValue;
	}
	
	/// ditto
	Image getImage()
	{
		assert(_info == typeid(Image) || _info == typeid(Bitmap)); // TODO
		return _innerValues.imageValue;
	}
	
	/// ditto
	Object getObject()
	{
		assert(!(cast(TypeInfo_Class)_info is null));
		return _innerValues.objectValue;
	}
	
	
private:
	TypeInfo _info;
	InnerValues _innerValues;

	///
	struct InnerValues
	{
		Data dataValue;
		Object objectValue;
		Dstring dstringValue;
		Dstring[] fileDropListValue;
		Ddstring ddstringValue;
		Dwstring dwstringValue;
		uint uintValue;
		int intValue;
		byte byteValue;
		byte[] bytesValue;
		ubyte[] ubytesValue;
		Image imageValue;
		dfl.data.IDataObject iDataObjectValue;
	}
}


/// Interface to a data object. The data can have different formats by setting different formats.
interface IDataObject
{
	///
	Data getData(Dstring fmt);
	/// ditto
	Data getData(TypeInfo type);
	/// ditto
	Data getData(Dstring fmt, bool doConvert);
	
	///
	bool getDataPresent(Dstring fmt);
	/// ditto
	bool getDataPresent(TypeInfo type);
	/// ditto
	bool getDataPresent(Dstring fmt, bool canConvert);
	
	///
	Dstring[] getFormats();
	
	///
	void setData(Data obj);
	/// ditto
	void setData(Dstring fmt, Data obj);
	/// ditto
	void setData(TypeInfo type, Data obj);
	/// ditto
	void setData(Dstring fmt, bool canConvert, Data obj);
}


///
class DataObject: dfl.data.IDataObject
{
	///
	Data getData(Dstring fmt)
	{
		return getData(fmt, true);
	}
	
	/// ditto
	Data getData(TypeInfo type)
	{
		Dstring fmt = DataFormats.getFormat(type).name;
		return getData(fmt);
	}
	
	/// ditto
	Data getData(Dstring fmt, bool doConvert)
	{
		// TODO: doConvert ...
		
		//cprintf("Looking for format '%.*s'.\n", fmt);
		int i = find(fmt);
		if(i == -1)
			throw new DflException("Data format not present");
		return _all[i].obj;
	}
	
	
	///
	bool getDataPresent(Dstring fmt)
	{
		return getDataPresent(fmt, true);
	}
	
	/// ditto
	bool getDataPresent(TypeInfo type)
	{
		Dstring fmt = DataFormats.getFormat(type).name;
		return getDataPresent(fmt);
	}
	
	/// ditto
	bool getDataPresent(Dstring fmt, bool canConvert)
	{
		// TODO: canConvert ...

		return find(fmt) != -1;
	}
	
	
	///
	Dstring[] getFormats()
	{
		Dstring[] result = new Dstring[_all.length];
		foreach(i, ref Dstring fmt; result)
		{
			fmt = _all[i].fmt;
		}
		return result;
	}
	
	
	/// Stores pair of format and data.
	/// When -replace- is true, stores new data with as a pair of preexist format.
	// Concrete implementation.
	package final void _setData(Dstring fmt, Data obj, bool replace = true)
	{
		if (obj._info == typeid(Dstring[]))
		{
			// Converts Dstring[] to Dstring ('\n' separated).
			Dstring resultString;
			Dstring[] sourceStrings = obj._innerValues.fileDropListValue;
			if (sourceStrings.length == 0)
			{
				resultString = "";
			}
			else if (sourceStrings.length == 1)
			{
				resultString = sourceStrings[0];
			}
			else
			{
				foreach (i, Dstring iter; sourceStrings[0 .. $-1])
				{
					resultString ~= iter ~ '\n';
				}
				resultString ~= sourceStrings[$-1];
			}
			obj._info = typeid(Dstring);
			obj._innerValues.fileDropListValue = null;
			obj._innerValues.dstringValue = resultString;
		}

		// 
		int i = find(fmt, false);
		if(i != -1)
		{
			if(replace)
				_all[i].obj = obj; // If found fmt in all, replace obj.
		}
		else
		{
			// If not found fmt in all, append new pair of fmt and obj.
			Pair pair;
			pair.fmt = fmt;
			pair.obj = obj;
			_all ~= pair;
		}
	}
	
	
	///
	void setData(Data obj)
	{
		Dstring fmt = DataFormats.getFormat(obj.info).name;
		setData(fmt, obj);
	}
	
	
	/// ditto
	void setData(Dstring fmt, Data obj)
	{
		setData(fmt, /+ canConvert: +/true, obj);
	}
	
	
	/// ditto
	void setData(TypeInfo type, Data obj)
	{
		Dstring fmt = DataFormats.getFormatFromType(type).name;
		setData(fmt, /+ canConvert: +/true, obj);
	}
	
	
	/// ditto
	void setData(Dstring fmt, bool canConvert, Data obj)
	{
		/+
		if(obj.info == typeid(Data))
		{
			void[] objv;
			objv = obj.value;
			assert(objv.length == Data.sizeof);
			obj = *(cast(Data*)objv.ptr);
		}
		+/
		
		_setData(fmt, obj);
		
		if(canConvert)
		{
			Data markedData = new _DataConvert(obj);
			_canConvertFormats(
				fmt, // toFmt
				(Dstring fromFmt) { _setData(fromFmt, markedData, false); }
			);
		}
	}
	
	
private:
	/// Pair has two fileds, Data that should be converted and correctly data format.
	/// Do fix obj when obj.info is _DataConvert.
	/// The obj's inner value should be fixed by fmt.
	struct Pair
	{
		Dstring fmt;
		Data obj;
	}
	
	
	Pair[] _all;
	
	
	///
	int find(Dstring fmt, bool fix = true)
	{
		for(size_t i = 0; i != _all.length; i++)
		{
			if(!stringICmp(_all[i].fmt, fmt))
			{
				assert(_all[i].obj);
				assert(_all[i].obj.info);
				if(fix && _all[i].obj.info == typeid(_DataConvert))
					fixPairEntry(_all[i]);
				return i.toI32;
			}
		}
		return -1;
	}
	
	
	///
	void fixPairEntry(ref Pair pr)
	{
		assert(pr.obj.info == typeid(_DataConvert));
		Data obj = pr.obj.getData();
		pr.obj = _doConvertFormat(obj, pr.fmt);
	}
}


/// Defined for marking _DataConvert tag to Data object.
/// When this object is created by coping Data object,
/// change Data.info value to typeid(_DataConvert),
/// but not change Data's inner value.
/// finally, Hold original Data into this._innerValues._dataValue.
private final class _DataConvert : Data
{
	this(Data data)
	{
		super(data);
		this._info = typeid(_DataConvert);
		this._innerValues = data._innerValues;
		this._innerValues.dataValue = data;
	}
}


/// 
package void _canConvertFormats(Dstring toFmt, void delegate(Dstring fromFmt) callback)
{
	// StringFormat(utf8)/UnicodeText/(Ansi)Text
	if(!stringICmp(toFmt, DataFormats.utf8))
	{
		callback(DataFormats.unicodeText);
		callback(DataFormats.text);
	}
	else if(!stringICmp(toFmt, DataFormats.unicodeText))
	{
		callback(DataFormats.utf8);
		callback(DataFormats.text);
	}
	else if(!stringICmp(toFmt, DataFormats.text))
	{
		callback(DataFormats.utf8);
		callback(DataFormats.unicodeText);
	}
	// Bitmap/DIB/DIBV5
	// else if(!stringICmp(toFmt, DataFormats.bitmap))
	// {
	// 	callback(DataFormats.dib);
	// 	callback(DataFormats.dibv5);
	// }
	// else if(!stringICmp(toFmt, DataFormats.dib))
	// {
	// 	callback(DataFormats.bitmap);
	// 	callback(DataFormats.dibv5);
	// }
	// else if(!stringICmp(toFmt, DataFormats.dibv5))
	// {
	// 	callback(DataFormats.bitmap);
	// 	callback(DataFormats.dib);
	// }
}

/// Get new Data instance that is converted format.
package Data _doConvertFormat(Data dat, Dstring toFmt)
{
	Data result;

	// StringFormat(utf8)/UnicodeText/(Ansi)Text
	if(!stringICmp(toFmt, DataFormats.utf8))
	{
		if(typeid(Dwstring) == dat.info)
		{
			result = new Data(utf16stringtoUtf8string(dat.getUnicodeText()));
		}
		else if(typeid(ubyte[]) == dat.info)
		{
			ubyte[] ubs;
			ubs = dat.getText();
			result = new Data(dfl.internal.utf.fromAnsi(cast(Dstringz)ubs.ptr, ubs.length));
		}
	}
	else if(!stringICmp(toFmt, DataFormats.unicodeText))
	{
		if(typeid(Dstring) == dat.info)
		{
			result = new Data(utf8stringtoUtf16string(dat.getString()));
		}
		else if(typeid(ubyte[]) == dat.info)
		{
			ubyte[] ubs;
			ubs = dat.getText();
			result = new Data(dfl.internal.utf.ansiToUnicode(cast(Dstringz)ubs.ptr, ubs.length));
		}
	}
	else if(!stringICmp(toFmt, DataFormats.text))
	{
		if(typeid(Dstring) == dat.info)
		{
			result = new Data(cast(ubyte[])dfl.internal.utf.toAnsi(dat.getString()));
		}
		else if(typeid(Dwstring) == dat.info)
		{
			Dwstring wcs;
			wcs = dat.getUnicodeText();
			result = new Data(cast(ubyte[])unicodeToAnsi(wcs.ptr, wcs.length));
		}
	}
	// Bitmap/DIB/DIBV5
	// else if(!stringICmp(toFmt, DataFormats.bitmap))
	// {
	// 	throw new DflException("Not implemented"); // TODO
	// }
	// else if(!stringICmp(toFmt, DataFormats.dib))
	// {
	// 	throw new DflException("Not implemented"); // TODO
	// }
	// else if(!stringICmp(toFmt, DataFormats.dibv5))
	// {
	// 	throw new DflException("Not implemented"); // TODO
	// }

	return result;
}


///
final class ComToDdataObject: dfl.data.IDataObject
{
	///
	this(dfl.internal.wincom.IDataObject dataObj)
	{
		_dataObj = dataObj;
		_dataObj.AddRef();
	}
	
	
	///
	~this()
	{
		_dataObj.Release(); // Must get called...
	}
	
	
	///
	private Data _getData(int id)
	{
		FORMATETC fmte;
		STGMEDIUM stgm;

		if (id == CF_BITMAP)
		{
			fmte.cfFormat = cast(CLIPFORMAT)id;
			fmte.ptd = null;
			fmte.dwAspect = DVASPECT_CONTENT;
			fmte.lindex = -1;
			fmte.tymed = TYMED_GDI;

			if (S_OK != _dataObj.QueryGetData(&fmte))
				throw new DflException("Unable to query get data");
			
			import std.format;
			HRESULT result = _dataObj.GetData(&fmte/+ in +/, &stgm/+ out +/);
			switch (result)
			{
			case S_OK:
				break;
			case DV_E_LINDEX:
				throw new DflException(format("Unable to get data: 0x%x", result));
			case DV_E_FORMATETC:
				throw new DflException(format("Unable to get data: 0x%x", result));
			case DV_E_TYMED:
				throw new DflException(format("Unable to get data: 0x%x", result));
			case DV_E_DVASPECT:
				throw new DflException(format("Unable to get data: 0x%x", result));
			case OLE_E_NOTRUNNING:
				throw new DflException(format("Unable to get data: 0x%x", result));
			case STG_E_MEDIUMFULL:
				throw new DflException(format("Unable to get data: 0x%x", result));
			case E_UNEXPECTED:
				throw new DflException(format("Unable to get data: 0x%x", result));
			case E_INVALIDARG:
				throw new DflException(format("Unable to get data: 0x%x", result));
			case E_OUTOFMEMORY:
				throw new DflException(format("Unable to get data: 0x%x", result));
			case CLIPBRD_E_BAD_DATA:
				throw new DflException(format("Unable to get data: 0x%x", result));
			default:
				throw new DflException(format("Unable to get data: 0x%x", result));
			}

			Image image = Image.fromHBitmap(stgm.hBitmap, true);
			ReleaseStgMedium(&stgm);
			return new Data(image);
		}
		else if (id == CF_TEXT
			||   id == CF_UNICODETEXT
			||   id == DataFormats.getFormat(DataFormats.stringFormat).id
			||   id == CF_HDROP)
		{
			fmte.cfFormat = cast(CLIPFORMAT)id;
			fmte.ptd = null;
			fmte.dwAspect = DVASPECT_CONTENT;
			fmte.lindex = -1;
			fmte.tymed = TYMED_HGLOBAL;

			if (S_OK != _dataObj.QueryGetData(&fmte))
				throw new DflException("Unable to query get data");
			
			if(S_OK != _dataObj.GetData(&fmte, &stgm))
				throw new DflException("Unable to get data");
			
			void* plock = GlobalLock(stgm.hGlobal);
			if(!plock)
			{
				ReleaseStgMedium(&stgm);
				throw new DflException("Error obtaining data");
			}
			
			void[] mem = new ubyte[GlobalSize(stgm.hGlobal)];
			mem[] = plock[0 .. mem.length];
			GlobalUnlock(stgm.hGlobal);
			ReleaseStgMedium(&stgm);
			
			return DataFormats.getDataFromFormat(id, mem);
		}
		else
		{
			throw new DflException("Not supported format in _getData()");
		}
	}
	
	/// ditto
	Data getData(Dstring fmt)
	{
		return _getData(DataFormats.getFormat(fmt).id);
	}
	
	/// ditto
	Data getData(TypeInfo type)
	{
		return _getData(DataFormats.getFormatFromType(type).id);
	}
	
	/// ditto
	Data getData(Dstring fmt, bool doConvert)
	{
		return getData(fmt); // TODO: ?
	}
	
	
	///
	private bool _getDataPresent(int id)
	{
		FORMATETC fmte;
		if(id == CF_BITMAP)
		{
			fmte.cfFormat = cast(CLIPFORMAT)id;
			fmte.ptd = null;
			fmte.dwAspect = DVASPECT_CONTENT; // TODO: ?
			fmte.lindex = -1;
			fmte.tymed = TYMED_GDI; // TODO: ?
		}
		else
		{
			fmte.cfFormat = cast(CLIPFORMAT)id;
			fmte.ptd = null;
			fmte.dwAspect = DVASPECT_CONTENT; // TODO: ?
			fmte.lindex = -1;
			fmte.tymed = TYMED_HGLOBAL; // TODO: ?
		}
		return S_OK == _dataObj.QueryGetData(&fmte);
	}
	
	
	/// ditto
	bool getDataPresent(Dstring fmt)
	{
		return _getDataPresent(DataFormats.getFormat(fmt).id);
	}
	
	/// ditto
	bool getDataPresent(TypeInfo type)
	{
		return _getDataPresent(DataFormats.getFormatFromType(type).id);
	}
	
	/// ditto
	bool getDataPresent(Dstring fmt, bool canConvert)
	{
		// TODO: canConvert ...

		return getDataPresent(fmt); // TODO: ?
	}
	
	
	///
	Dstring[] getFormats()
	{
		IEnumFORMATETC fenum;
		FORMATETC fmte;
		Dstring[] result;
		ULONG nfetched;
		
		if(S_OK != _dataObj.EnumFormatEtc(DATADIR_GET, &fenum))
			throw new DflException("Unable to get formats");
		
		for(;;)
		{
			if(S_OK != fenum.Next(1, &fmte, &nfetched))
				break;
			if(!nfetched)
				break;
			//cprintf("\t\t{getFormats:%d}\n", fmte.cfFormat);
			result ~= DataFormats.getFormat(fmte.cfFormat).name;
		}
		// https://learn.microsoft.com/en-us/windows/win32/api/objidl/nf-objidl-idataobject-enumformatetc
		fenum.Release();
		
		return result;
	}
	
	
	///
	private void _setData(int id, Data obj)
	{
		/+
		FORMATETC fmte;
		STGMEDIUM stgm;
		HANDLE hmem;
		void[] mem;
		void* pmem;
		
		mem = DataFormats.getClipboardValueFromData(id, obj);
		
		hmem = GlobalAlloc(GMEM_SHARE, mem.length);
		if(!hmem)
		{
			//cprintf("Unable to GlobalAlloc().\n");
			err_set:
			throw new DflException("Unable to set data");
		}
		pmem = GlobalLock(hmem);
		if(!pmem)
		{
			//cprintf("Unable to GlobalLock().\n");
			GlobalFree(hmem);
			goto err_set;
		}
		pmem[0 .. mem.length] = mem;
		GlobalUnlock(hmem);
		
		fmte.cfFormat = cast(CLIPFORMAT)id;
		fmte.ptd = null;
		fmte.dwAspect = DVASPECT_CONTENT; // ?
		fmte.lindex = -1;
		fmte.tymed = TYMED_HGLOBAL;
		
		stgm.tymed = TYMED_HGLOBAL;
		stgm.hGlobal = hmem;
		stgm.pUnkForRelease = null;
		
		// -dataObj- now owns the handle.
		HRESULT hr = dataObj.SetData(&fmte, &stgm, true);
		if(S_OK != hr)
		{
			//cprintf("Unable to IDataObject::SetData() = %d (0x%X).\n", hr, hr);
			// Failed, need to free it..
			GlobalFree(hmem);
			goto err_set;
		}
		+/
		// Don't set stuff in someone else's data object.
		throw new DflException("DFL: ComToDdataObject._setData() is not implemented.");
	}
	
	/// ditto
	void setData(Data obj)
	{
		_setData(DataFormats.getFormatFromType(obj.info).id, obj);
	}
	
	/// ditto
	void setData(Dstring fmt, Data obj)
	{
		_setData(DataFormats.getFormat(fmt).id, obj);
	}
	
	/// ditto
	void setData(TypeInfo type, Data obj)
	{
		_setData(DataFormats.getFormatFromType(type).id, obj);
	}
	
	/// ditto
	void setData(Dstring fmt, bool canConvert, Data obj)
	{
		// TODO: canConvert ...

		setData(fmt, obj); // TODO: ?
	}
	
	
	///
	final bool isSameDataObject(dfl.internal.wincom.IDataObject dataObj)
	{
		return dataObj is _dataObj;
	}
	
	
private:
	dfl.internal.wincom.IDataObject _dataObj;
}


///
final class EnumDataObjectFORMATETC: DflComObject, IEnumFORMATETC
{
	///
	this(dfl.data.IDataObject dataObj, Dstring[] fmts, ULONG start)
	{
		_dataObj = dataObj;
		_fmts = fmts;
		_idx = start;
	}
	
	/// ditto
	this(dfl.data.IDataObject dataObj)
	{
		this(dataObj, dataObj.getFormats(), 0);
	}
	
	
extern(Windows):
	/// 
	override HRESULT QueryInterface(IID* riid, void** ppv)
	{
		if(*riid == _IID_IEnumFORMATETC)
		{
			*ppv = cast(void*)cast(IEnumFORMATETC)this;
			AddRef();
			return S_OK;
		}
		else if(*riid == _IID_IUnknown)
		{
			*ppv = cast(void*)cast(IUnknown)this;
			AddRef();
			return S_OK;
		}
		else
		{
			*ppv = null;
			return E_NOINTERFACE;
		}
	}
	
	
	///
	// [in]    ULONG celt
	// [out]   FORMATETC* rgelt
	// [inout] ULONG* pceltFetched
	HRESULT Next(ULONG celt, FORMATETC* rgelt, ULONG* pceltFetched)
	{
		HRESULT result;
		
		try
		{
			if(_idx < _fmts.length)
			{
				ULONG end = _idx + celt;
				if(end > _fmts.length)
				{
					result = S_FALSE; // TODO: ?
					end = _fmts.length.toI32;
					
					if(pceltFetched)
						*pceltFetched = end - _idx;
				}
				else
				{
					result = S_OK;
					
					if(pceltFetched)
						*pceltFetched = celt;
				}

				for(; _idx != end; _idx++)
				{
					int id = DataFormats.getFormat(_fmts[_idx]).id;
					if (id == CF_BITMAP)
					{
						rgelt.cfFormat = cast(CLIPFORMAT)id;
						rgelt.ptd = null;
						rgelt.dwAspect = DVASPECT_CONTENT;
						rgelt.lindex = -1;
						rgelt.tymed = TYMED_GDI;
					}
					else
					{
						rgelt.cfFormat = cast(CLIPFORMAT)id;
						rgelt.ptd = null;
						rgelt.dwAspect = DVASPECT_CONTENT;
						rgelt.lindex = -1;
						rgelt.tymed = TYMED_HGLOBAL;
					}
					
					rgelt++;
				}
			}
			else
			{
				if(pceltFetched)
					*pceltFetched = 0;
				result = S_FALSE;
			}
		}
		catch(DThrowable e)
		{
			Application.onThreadException(e);
			
			result = E_UNEXPECTED;
		}
		
		return result;
	}
	
	
	///
	// [in] ULONG celt
	HRESULT Skip(ULONG celt)
	{
		_idx += celt;
		return (_idx > _fmts.length) ? S_FALSE : S_OK;
	}
	
	
	///
	HRESULT Reset()
	{
		try
		{
			_idx = 0;
			_fmts = _dataObj.getFormats();
			
			return S_OK;
		}
		catch(DThrowable e)
		{
			Application.onThreadException(e);
			
			return E_UNEXPECTED;
		}
	}
	
	
	///
	// [out] IEnumFORMATETC* ppenum
	HRESULT Clone(IEnumFORMATETC* ppenum)
	{
		try
		{
			*ppenum = new EnumDataObjectFORMATETC(_dataObj, _fmts, _idx);

			return S_OK;
		}
		catch(DThrowable e)
		{
			Application.onThreadException(e);
			
			return E_UNEXPECTED;
		}
	}
	
	
extern(D):
	
private:
	dfl.data.IDataObject _dataObj;
	Dstring[] _fmts;
	ULONG _idx;
}


///
final class DtoComDataObject: DflComObject, dfl.internal.wincom.IDataObject
{
	///
	this(dfl.data.IDataObject dataObj)
	{
		_dataObj = dataObj;

		CLIPFORMAT _getIdFromFormat(Dstring fmt)
		{
			return cast(CLIPFORMAT)DataFormats.getFormat(fmt).id;
		}

		_formatetcList ~= FORMATETC(CF_BITMAP, null, DVASPECT_CONTENT, -1, TYMED_GDI);

		_formatetcList ~= FORMATETC(CF_TEXT, null, DVASPECT_CONTENT, -1, TYMED_HGLOBAL);
		_formatetcList ~= FORMATETC(CF_UNICODETEXT, null, DVASPECT_CONTENT, -1, TYMED_HGLOBAL);
		_formatetcList ~= FORMATETC(_getIdFromFormat(DataFormats.stringFormat), null, DVASPECT_CONTENT, -1, TYMED_HGLOBAL);

		_formatetcList ~= FORMATETC(CF_HDROP, null, DVASPECT_CONTENT, -1, TYMED_HGLOBAL);
	}

	
extern(Windows):
	
	///
	// [in]  IID* riid
	// [out] void** ppv
	override HRESULT QueryInterface(IID* riid, void** ppv)
	{
		if(*riid == _IID_IDataObject)
		{
			*ppv = cast(void*)cast(dfl.internal.wincom.IDataObject)this;
			AddRef();
			return S_OK;
		}
		else if(*riid == _IID_IUnknown)
		{
			*ppv = cast(void*)cast(IUnknown)this;
			AddRef();
			return S_OK;
		}
		else
		{
			*ppv = null;
			return E_NOINTERFACE;
		}
	}
	
	
	///
	// [in]  FORMATETC* pFormatetc
	// [out] STGMEDIUM* pmedium
	HRESULT GetData(FORMATETC* pFormatetc, STGMEDIUM* pmedium)
	{
		try
		{
			if (!isSupportedFormatetc(pFormatetc))
			{
				return DV_E_FORMATETC;
			}

			if (pFormatetc.cfFormat == CF_BITMAP)
			{
				if (pFormatetc.tymed & TYMED_GDI)
				{
					DataFormats.Format fmt = DataFormats.getFormat(pFormatetc.cfFormat);
					Data data = _dataObj.getData(fmt.name, true); // Should this be convertable?
					Bitmap bitmap = cast(Bitmap)data.getImage();
				
					pmedium.tymed = TYMED_GDI;
					pmedium.hBitmap = bitmap.handle;
					pmedium.pUnkForRelease = null;
				}
				else
				{
					return DV_E_TYMED;
				}
			}
			else if (pFormatetc.cfFormat == CF_TEXT
				||   pFormatetc.cfFormat == CF_UNICODETEXT
				||   pFormatetc.cfFormat == DataFormats.getFormat(DataFormats.stringFormat).id
				||   pFormatetc.cfFormat == CF_HDROP)
				// TODO: other format ...
			{
				if (pFormatetc.tymed & TYMED_HGLOBAL)
				{
					DataFormats.Format fmt = DataFormats.getFormat(pFormatetc.cfFormat);
					Data data = _dataObj.getData(fmt.name, true); // Should this be convertable?
					
					void[] src = DataFormats.getClipboardValueFromData(fmt.id, data);
					HGLOBAL hg = GlobalAlloc(GMEM_SHARE, src.length.toI32);
					if(!hg)
					{
						return STG_E_MEDIUMFULL;
					}

					void* pmem = GlobalLock(hg);
					if(!pmem)
					{
						GlobalFree(hg);
						return E_UNEXPECTED;
					}

					pmem[0 .. src.length] = src[];
					GlobalUnlock(hg);
					
					pmedium.tymed = TYMED_HGLOBAL;
					pmedium.hGlobal = hg;
					pmedium.pUnkForRelease = null;
				}
				else
				{
					return DV_E_TYMED;
				}
			}
			else
			{
				return DV_E_FORMATETC;
			}
		}
		catch(DflException e)
		{
			//Application.onThreadException(e);
			
			return DV_E_FORMATETC;
		}
		catch(OomException e)
		{
			Application.onThreadException(e);
			
			return E_OUTOFMEMORY;
		}
		catch(DThrowable e)
		{
			Application.onThreadException(e);
			
			return E_UNEXPECTED;
		}
		
		return S_OK;
	}
	
	
	///
	// [in]  FORMATETC* pFormatetc
	// [out] STGMEDIUM* pmedium
	HRESULT GetDataHere(FORMATETC* pFormatetc, STGMEDIUM* pmedium)
	{
		return DATA_E_FORMATETC; // TODO: finish.
	}
	
	
	///
	// [in] FORMATETC* pFormatetc
	HRESULT QueryGetData(FORMATETC* pFormatetc)
	{
		try
		{
			if (!isSupportedFormatetc(pFormatetc))
			{
				return S_FALSE;
			}

			Dstring fmt = DataFormats.getFormat(pFormatetc.cfFormat).name;
			if(!_dataObj.getDataPresent(fmt))
			{
				return S_FALSE;
			}
		}
		catch(DflException e)
		{
			//Application.onThreadException(e);
			
			return DV_E_FORMATETC;
		}
		catch(OomException e)
		{
			Application.onThreadException(e);
			
			return E_OUTOFMEMORY;
		}
		catch(DThrowable e)
		{
			Application.onThreadException(e);
			
			return E_UNEXPECTED;
		}
		
		return S_OK;
	}
	
	///
	// [in]  FORMATETC* pFormatetcIn
	// [out] FORMATETC* pFormatetcOut
	HRESULT GetCanonicalFormatEtc(FORMATETC* pFormatetcIn, FORMATETC* pFormatetcOut)
	{
		pFormatetcOut.ptd = null;
		return E_NOTIMPL;
	}
	
	
	///
	// [in]  FORMATETC* pFormatetc
	// [out] STGMEDIUM* pmedium
	// [in]  BOOL fRelease
	HRESULT SetData(FORMATETC* pFormatetc, STGMEDIUM* pmedium, BOOL fRelease)
	{
		return E_NOTIMPL;
	}
	
	
	///
	// [in]  DWORD dwDirection
	// [out] IEnumFORMATETC* ppenumFormatetc
	HRESULT EnumFormatEtc(DWORD dwDirection, IEnumFORMATETC* ppenumFormatetc)
	{
		// SHCreateStdEnumFmtEtc() requires Windows 2000 +
		
		try
		{
			if(dwDirection == DATADIR_GET)
			{
				*ppenumFormatetc = new EnumDataObjectFORMATETC(_dataObj);
				return S_OK;
			}
			else if(dwDirection == DATADIR_SET)
			{
				return E_NOTIMPL;
			}
			else
			{
				return E_INVALIDARG;
			}
		}
		catch(DThrowable e)
		{
			Application.onThreadException(e);
			
			return E_UNEXPECTED;
		}
	}
	
	
	///
	// [in]  FORMATETC* pFormatetc
	// [in]  DWORD advf
	// [in]  IAdviseSink pAdvSink
	// [out] DWORD* pdwConnection
	HRESULT DAdvise(FORMATETC* pFormatetc, DWORD advf, IAdviseSink pAdvSink, DWORD* pdwConnection)
	{
		return OLE_E_ADVISENOTSUPPORTED;
	}
	
	
	///
	// [in]  DWORD dwConnection
	HRESULT DUnadvise(DWORD dwConnection)
	{
		return OLE_E_ADVISENOTSUPPORTED;
	}
	
	
	///
	// [out] IEnumSTATDATA* ppenumAdvise
	HRESULT EnumDAdvise(IEnumSTATDATA* ppenumAdvise)
	{
		return OLE_E_ADVISENOTSUPPORTED;
	}
	
	
extern(D):
	
private:
	///
	bool isSupportedFormatetc(const FORMATETC* pFormatetc) const
	{
		foreach (ref const FORMATETC f; _formatetcList)
		{
			if ((f.tymed & pFormatetc.tymed)
				&& f.cfFormat == pFormatetc.cfFormat
				&& f.dwAspect == pFormatetc.dwAspect
				&& f.lindex == pFormatetc.lindex)
			{
				return true;
			}
		}
		return false;
	}
	
	dfl.data.IDataObject _dataObj;
	FORMATETC[] _formatetcList;
}


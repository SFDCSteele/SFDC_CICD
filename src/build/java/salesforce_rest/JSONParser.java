/**
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package salesforce_rest;


import java.io.IOException;
import java.io.Reader;
import java.io.Writer;
import java.nio.CharBuffer;
import java.util.Arrays;
import java.util.Collection;
import java.util.Map;
import java.util.Set;

/**
 * @author yonik
 * @version $Id: JSONParser.java 730138 2008-12-30 14:54:53Z yonik $
 */

public class JSONParser {

  /** Event indicating a JSON string value, including member names of objects */
  public static final int STRING = 1;

  /**
   * Event indicating a JSON number value which fits into a signed 64 bit
   * integer
   */
  public static final int LONG = 2;

  /**
   * Event indicating a JSON number value which has a fractional part or an
   * exponent and with string length <= 23 chars not including sign. This covers
   * all representations of normal values for Double.toString().
   */
  public static final int NUMBER = 3;

  /**
   * Event indicating a JSON number value that was not produced by toString of
   * any Java primitive numerics such as Double or Long. It is either an integer
   * outside the range of a 64 bit signed integer, or a floating point value
   * with a string representation of more than 23 chars.
   */
  public static final int BIGNUMBER = 4;

  /** Event indicating a JSON boolean */
  public static final int BOOLEAN = 5;

  /** Event indicating a JSON null */
  public static final int NULL = 6;

  /** Event indicating the start of a JSON object */
  public static final int OBJECT_START = 7;

  /** Event indicating the end of a JSON object */
  public static final int OBJECT_END = 8;

  /** Event indicating the start of a JSON array */
  public static final int ARRAY_START = 9;

  /** Event indicating the end of a JSON array */
  public static final int ARRAY_END = 10;

  /** Event indicating the end of input has been reached */
  public static final int EOF = 11;

  public static String getEventString(int e) {
    switch (e) {
    case STRING:
      return "STRING";
    case LONG:
      return "LONG";
    case NUMBER:
      return "NUMBER";
    case BIGNUMBER:
      return "BIGNUMBER";
    case BOOLEAN:
      return "BOOLEAN";
    case NULL:
      return "NULL";
    case OBJECT_START:
      return "OBJECT_START";
    case OBJECT_END:
      return "OBJECT_END";
    case ARRAY_START:
      return "ARRAY_START";
    case ARRAY_END:
      return "ARRAY_END";
    case EOF:
      return "EOF";
    }
    return "Unknown: " + e;
  }

  private static final CharArr devNull = new NullCharArr();

  final char[] buf; // input buffer with JSON text in it

  int start; // current position in the buffer

  int end; // end position in the buffer (one past last valid index)

  final Reader in; // optional reader to obtain data from

  boolean eof = false; // true if the end of the stream was reached.

  long gpos; // global position = gpos + start

  int event; // last event read

  public JSONParser(Reader in) {
    this(in, new char[8192]);
    // 8192 matches the default buffer size of a BufferedReader so double
    // buffering of the data is avoided.
  }

  public JSONParser(Reader in, char[] buffer) {
    this.in = in;
    this.buf = buffer;
  }

  // idea - if someone passes us a CharArrayReader, we could
  // directly use that buffer as it's protected.

  public JSONParser(char[] data, int start, int end) {
    this.in = null;
    this.buf = data;
    this.start = start;
    this.end = end;
  }

  public JSONParser(String data) {
    this(data, 0, data.length());
  }

  public JSONParser(String data, int start, int end) {
    this.in = null;
    this.start = start;
    this.end = end;
    this.buf = new char[end - start];
    data.getChars(start, end, buf, 0);
  }

  // temporary output buffer
  private final CharArr out = new CharArr(64);

  // We need to keep some state in order to (at a minimum) know if
  // we should skip ',' or ':'.
  private byte[] stack = new byte[16];

  private int ptr = 0; // pointer into the stack of parser states

  private byte state = 0; // current parser state

  // parser states stored in the stack
  private static final byte DID_OBJSTART = 1; // '{' just read

  private static final byte DID_ARRSTART = 2; // '[' just read

  private static final byte DID_ARRELEM = 3; // array element just read

  private static final byte DID_MEMNAME = 4; // object member name (map key)

  // just read

  private static final byte DID_MEMVAL = 5; // object member value (map val)

  // just read

  // info about value that was just read (or is in the middle of being read)
  private int valstate;

  // push current parser state (use at start of new container)
  private final void push() {
    if (ptr >= stack.length) {
      // doubling here is probably overkill, but anything that needs to double
      // more than
      // once (32 levels deep) is very atypical anyway.
      byte[] newstack = new byte[stack.length << 1];
      System.arraycopy(stack, 0, newstack, 0, stack.length);
      stack = newstack;
    }
    stack[ptr++] = state;
  }

  // pop parser state (use at end of container)
  private final void pop() {
    if (--ptr < 0) {
      throw err("Unbalanced container");
    } else {
      state = stack[ptr];
    }
  }

  protected void fill() throws IOException {
    if (in != null) {
      gpos += end;
      start = 0;
      int num = in.read(buf, 0, buf.length);
      end = num >= 0 ? num : 0;
    }
    if (start >= end)
      eof = true;
  }

  private void getMore() throws IOException {
    fill();
    if (start >= end) {
      throw err(null);
    }
  }

  protected int getChar() throws IOException {
    if (start >= end) {
      fill();
      if (start >= end)
        return -1;
    }
    return buf[start++];
  }

  private int getCharNWS() throws IOException {
    for (;;) {
      int ch = getChar();
      if (!(ch == ' ' || ch == '\t' || ch == '\n' || ch == '\r'))
        return ch;
    }
  }

  private void expect(char[] arr) throws IOException {
    for (int i = 1; i < arr.length; i++) {
      int ch = getChar();
      if (ch != arr[i]) {
        if (ch == -1)
          throw new RuntimeException("Unexpected EOF");
        throw new RuntimeException("Expected " + new String(arr));
      }
    }
  }

  private RuntimeException err(String msg) {
    // We can't tell if EOF was hit by comparing start<=end
    // because the illegal char could have been the last in the buffer
    // or in the stream. To deal with this, the "eof" var was introduced
    if (!eof && start > 0)
      start--; // backup one char
    String chs = "char=" + ((start >= end) ? "(EOF)" : "" + (char) buf[start]);
    String pos = "position=" + (gpos + start);
    String tot = chs + ',' + pos;
    if (msg == null) {
      if (start >= end)
        msg = "Unexpected EOF";
      else
        msg = "JSON Parse Error";
    }
    return new RuntimeException(msg + ": " + tot);
  }

  private boolean bool; // boolean value read

  private long lval; // long value read

  private int nstate; // current state while reading a number

  private static final int HAS_FRACTION = 0x01; // nstate flag, '.' already read

  private static final int HAS_EXPONENT = 0x02; // nstate flag, '[eE][+-]?[0-9]'

  // already read

  /**
   * Returns the long read... only significant if valstate==LONG after this
   * call. firstChar should be the first numeric digit read.
   */
  private long readNumber(int firstChar, boolean isNeg) throws IOException {
    out.unsafeWrite(firstChar); // unsafe OK since we know output is big enough
    // We build up the number in the negative plane since it's larger (by one)
    // than
    // the positive plane.
    long v = '0' - firstChar;
    for (int i = 0; i < 22; i++) {
      int ch = getChar();
      // TODO: is this switch faster as an if-then-else?
      switch (ch) {
      case '0':
      case '1':
      case '2':
      case '3':
      case '4':
      case '5':
      case '6':
      case '7':
      case '8':
      case '9':
        v = v * 10 - (ch - '0');
        out.unsafeWrite(ch);
        continue;
      case '.':
        out.unsafeWrite('.');
        valstate = readFrac(out, 22 - i);
        return 0;
      case 'e':
      case 'E':
        out.unsafeWrite(ch);
        nstate = 0;
        valstate = readExp(out, 22 - i);
        return 0;
      default:
        // return the number, relying on nextEvent() to return an error
        // for invalid chars following the number.
        if (ch != -1)
          --start; // push back last char if not EOF

        // the max number of digits we are reading only allows for
        // a long to wrap once, so we can just check if the sign is
        // what is expected to detect an overflow.
        if (isNeg) {
          // -0 is allowed by the spec
          valstate = v <= 0 ? LONG : BIGNUMBER;
        } else {
          v = -v;
          valstate = v >= 0 ? LONG : BIGNUMBER;
        }
        return v;
      }
    }
    nstate = 0;
    valstate = BIGNUMBER;
    return 0;
  }

  // read digits right of decimal point
  private int readFrac(CharArr arr, int lim) throws IOException {
    nstate = HAS_FRACTION; // deliberate set instead of '|'
    while (--lim >= 0) {
      int ch = getChar();
      if (ch >= '0' && ch <= '9') {
        arr.write(ch);
      } else if (ch == 'e' || ch == 'E') {
        arr.write(ch);
        return readExp(arr, lim);
      } else {
        if (ch != -1)
          start--; // back up
        return NUMBER;
      }
    }
    return BIGNUMBER;
  }

  // call after 'e' or 'E' has been seen to read the rest of the exponent
  private int readExp(CharArr arr, int lim) throws IOException {
    nstate |= HAS_EXPONENT;
    int ch = getChar();
    lim--;

    if (ch == '+' || ch == '-') {
      arr.write(ch);
      ch = getChar();
      lim--;
    }

    // make sure at least one digit is read.
    if (ch < '0' || ch > '9') {
      throw err("missing exponent number");
    }
    arr.write(ch);

    return readExpDigits(arr, lim);
  }

  // continuation of readExpStart
  private int readExpDigits(CharArr arr, int lim) throws IOException {
    while (--lim >= 0) {
      int ch = getChar();
      if (ch >= '0' && ch <= '9') {
        arr.write(ch);
      } else {
        if (ch != -1)
          start--; // back up
        return NUMBER;
      }
    }
    return BIGNUMBER;
  }

  private void continueNumber(CharArr arr) throws IOException {
    if (arr != out)
      arr.write(out);

    if ((nstate & HAS_EXPONENT) != 0) {
      readExpDigits(arr, Integer.MAX_VALUE);
      return;
    }
    if (nstate != 0) {
      readFrac(arr, Integer.MAX_VALUE);
      return;
    }

    for (;;) {
      int ch = getChar();
      if (ch >= '0' && ch <= '9') {
        arr.write(ch);
      } else if (ch == '.') {
        arr.write(ch);
        readFrac(arr, Integer.MAX_VALUE);
        return;
      } else if (ch == 'e' || ch == 'E') {
        arr.write(ch);
        readExp(arr, Integer.MAX_VALUE);
        return;
      } else {
        if (ch != -1)
          start--;
        return;
      }
    }
  }

  private int hexval(int hexdig) {
    if (hexdig >= '0' && hexdig <= '9') {
      return hexdig - '0';
    } else if (hexdig >= 'A' && hexdig <= 'F') {
      return hexdig + (10 - 'A');
    } else if (hexdig >= 'a' && hexdig <= 'f') {
      return hexdig + (10 - 'a');
    }
    throw err("invalid hex digit");
  }

  // backslash has already been read when this is called
  private char readEscapedChar() throws IOException {
    switch (getChar()) {
    case '"':
      return '"';
    case '\\':
      return '\\';
    case '/':
      return '/';
    case 'n':
      return '\n';
    case 'r':
      return '\r';
    case 't':
      return '\t';
    case 'f':
      return '\f';
    case 'b':
      return '\b';
    case 'u':
      return (char) ((hexval(getChar()) << 12) | (hexval(getChar()) << 8)
          | (hexval(getChar()) << 4) | (hexval(getChar())));
    }
    throw err("Invalid character escape in string");
  }

  // a dummy buffer we can use to point at other buffers
  private final CharArr tmp = new CharArr(null, 0, 0);

  private CharArr readStringChars() throws IOException {
    char c = 0;
    int i;
    for (i = start; i < end; i++) {
      c = buf[i];
      if (c == '"') {
        tmp.set(buf, start, i); // directly use input buffer
        start = i + 1; // advance past last '"'
        return tmp;
      } else if (c == '\\') {
        break;
      }
    }
    out.reset();
    readStringChars2(out, i);
    return out;
  }

  // middle is the pointer to the middle of a buffer to start scanning for a
  // non-string
  // character ('"' or "/"). start<=middle<end
  // this should be faster for strings with fewer escapes, but probably slower
  // for many escapes.
  private void readStringChars2(CharArr arr, int middle) throws IOException {
    for (;;) {
      if (middle >= end) {
        arr.write(buf, start, middle - start);
        getMore();
        middle = start;
      }
      int ch = buf[middle++];
      if (ch == '"') {
        int len = middle - start - 1;
        if (len > 0)
          arr.write(buf, start, len);
        start = middle;
        return;
      } else if (ch == '\\') {
        int len = middle - start - 1;
        if (len > 0)
          arr.write(buf, start, len);
        start = middle;
        arr.write(readEscapedChar());
        middle = start;
      }
    }
  }

  /*****************************************************************************
   * * alternate implelentation // middle is the pointer to the middle of a
   * buffer to start scanning for a non-string // character ('"' or "/"). start<=middle<end
   * private void readStringChars2a(CharArr arr, int middle) throws IOException {
   * int ch=0; for(;;) { // find the next non-string char for (; middle<end;
   * middle++) { ch = buf[middle]; if (ch=='"' || ch=='\\') break; }
   * 
   * arr.write(buf,start,middle-start); if (middle>=end) { getMore();
   * middle=start; } else { start = middle+1; // set buffer pointer to correct
   * spot if (ch=='"') { valstate=0; return; } else if (ch=='\\') {
   * arr.write(readEscapedChar()); if (start>=end) getMore(); middle=start; } } } }
   ****************************************************************************/

  // return the next event when parser is in a neutral state (no
  // map separators or array element separators to read
  private int next(int ch) throws IOException {
    for (;;) {
      switch (ch) {
      case ' ':
      case '\t':
        break;
      case '\r':
      case '\n':
        break; // try and keep track of linecounts?
      case '"':
        valstate = STRING;
        return STRING;
      case '{':
        push();
        state = DID_OBJSTART;
        return OBJECT_START;
      case '[':
        push();
        state = DID_ARRSTART;
        return ARRAY_START;
      case '0':
        out.reset();
        // special case '0'? If next char isn't '.' val=0
        ch = getChar();
        if (ch == '.') {
          start--;
          ch = '0';
          readNumber('0', false);
          return valstate;
        } else if (ch > '9' || ch < '0') {
          out.unsafeWrite('0');
          start--;
          lval = 0;
          valstate = LONG;
          return LONG;
        } else {
          throw err("Leading zeros not allowed");
        }
      case '1':
      case '2':
      case '3':
      case '4':
      case '5':
      case '6':
      case '7':
      case '8':
      case '9':
        out.reset();
        lval = readNumber(ch, false);
        return valstate;
      case '-':
        out.reset();
        out.unsafeWrite('-');
        ch = getChar();
        if (ch < '0' || ch > '9')
          throw err("expected digit after '-'");
        lval = readNumber(ch, true);
        return valstate;
      case 't':
        valstate = BOOLEAN;
        // TODO: test performance of this non-branching inline version.
        // if ((('r'-getChar())|('u'-getChar())|('e'-getChar())) != 0) err("");
        expect(JSONUtil.TRUE_CHARS);
        bool = true;
        return BOOLEAN;
      case 'f':
        valstate = BOOLEAN;
        expect(JSONUtil.FALSE_CHARS);
        bool = false;
        return BOOLEAN;
      case 'n':
        valstate = NULL;
        expect(JSONUtil.NULL_CHARS);
        return NULL;
      case -1:
        if (getLevel() > 0)
          throw new RuntimeException("Premature EOF");
        return EOF;
      default:
        throw err(null);
      }

      ch = getChar();
    }
  }

  public String toString() {
    return "start=" + start + ",end=" + end + ",state=" + state + "valstate=" + valstate;
  }

  /**
   * Returns the next event encountered in the JSON stream, one of
   * <ul>
   * <li>{@link #STRING}</li>
   * <li>{@link #LONG}</li>
   * <li>{@link #NUMBER}</li>
   * <li>{@link #BIGNUMBER}</li>
   * <li>{@link #BOOLEAN}</li>
   * <li>{@link #NULL}</li>
   * <li>{@link #OBJECT_START}</li>
   * <li>{@link #OBJECT_END}</li>
   * <li>{@link #OBJECT_END}</li>
   * <li>{@link #ARRAY_START}</li>
   * <li>{@link #ARRAY_END}</li>
   * <li>{@link #EOF}</li>
   * </ul>
   */
  public int nextEvent() throws IOException {
    if (valstate == STRING) {
      readStringChars2(devNull, start);
    } else if (valstate == BIGNUMBER) {
      continueNumber(devNull);
    }

    valstate = 0;

    int ch; // TODO: factor out getCharNWS() to here and check speed
    switch (state) {
    case 0:
      return event = next(getCharNWS());
    case DID_OBJSTART:
      ch = getCharNWS();
      if (ch == '}') {
        pop();
        return event = OBJECT_END;
      }
      if (ch != '"') {
        throw err("Expected string");
      }
      state = DID_MEMNAME;
      valstate = STRING;
      return event = STRING;
    case DID_MEMNAME:
      ch = getCharNWS();
      if (ch != ':') {
        throw err("Expected key,value separator ':'");
      }
      state = DID_MEMVAL; // set state first because it might be pushed...
      return event = next(getChar());
    case DID_MEMVAL:
      ch = getCharNWS();
      if (ch == '}') {
        pop();
        return event = OBJECT_END;
      } else if (ch != ',') {
        throw err("Expected ',' or '}'");
      }
      ch = getCharNWS();
      if (ch != '"') {
        throw err("Expected string");
      }
      state = DID_MEMNAME;
      valstate = STRING;
      return event = STRING;
    case DID_ARRSTART:
      ch = getCharNWS();
      if (ch == ']') {
        pop();
        return event = ARRAY_END;
      }
      state = DID_ARRELEM; // set state first, might be pushed...
      return event = next(ch);
    case DID_ARRELEM:
      ch = getCharNWS();
      if (ch == ']') {
        pop();
        return event = ARRAY_END;
      } else if (ch != ',') {
        throw err("Expected ',' or ']'");
      }
      // state = DID_ARRELEM;
      return event = next(getChar());
    }
    return 0;
  }

  public int lastEvent() {
    return event;
  }

  public boolean wasKey() {
    return state == DID_MEMNAME;
  }

  private void goTo(int what) throws IOException {
    if (valstate == what) {
      valstate = 0;
      return;
    }
    if (valstate == 0) {
      int ev = nextEvent(); // TODO
      if (valstate != what) {
        throw err("type mismatch");
      }
      valstate = 0;
    } else {
      throw err("type mismatch");
    }
  }

  /** Returns the JSON string value, decoding any escaped characters. */
  public String getString() throws IOException {
    return getStringChars().toString();
  }

  /**
   * Returns the characters of a JSON string value, decoding any escaped
   * characters. <p/>The underlying buffer of the returned <code>CharArr</code>
   * should *not* be modified as it may be shared with the input buffer. <p/>The
   * returned <code>CharArr</code> will only be valid up until the next
   * JSONParser method is called. Any required data should be read before that
   * point.
   */
  public CharArr getStringChars() throws IOException {
    goTo(STRING);
    return readStringChars();
  }

  /** Reads a JSON string into the output, decoding any escaped characters. */
  public void getString(CharArr output) throws IOException {
    goTo(STRING);
    readStringChars2(output, start);
  }

  /**
   * Reads a number from the input stream and parses it as a long, only if the
   * value will in fact fit into a signed 64 bit integer.
   */
  public long getLong() throws IOException {
    goTo(LONG);
    return lval;
  }

  /** Reads a number from the input stream and parses it as a double */
  public double getDouble() throws IOException {
    return Double.parseDouble(getNumberChars().toString());
  }

  /**
   * Returns the characters of a JSON numeric value. <p/>The underlying buffer
   * of the returned <code>CharArr</code> should *not* be modified as it may
   * be shared with the input buffer. <p/>The returned <code>CharArr</code>
   * will only be valid up until the next JSONParser method is called. Any
   * required data should be read before that point.
   */
  public CharArr getNumberChars() throws IOException {
    int ev = 0;
    if (valstate == 0)
      ev = nextEvent();

    if (valstate == LONG || valstate == NUMBER) {
      valstate = 0;
      return out;
    } else if (valstate == BIGNUMBER) {
      continueNumber(out);
      valstate = 0;
      return out;
    } else {
      throw err("Unexpected " + ev);
    }
  }

  /** Reads a JSON numeric value into the output. */
  public void getNumberChars(CharArr output) throws IOException {
    int ev = 0;
    if (valstate == 0)
      ev = nextEvent();
    if (valstate == LONG || valstate == NUMBER)
      output.write(this.out);
    else if (valstate == BIGNUMBER) {
      continueNumber(output);
    } else {
      throw err("Unexpected " + ev);
    }
    valstate = 0;
  }

  /** Reads a boolean value */
  public boolean getBoolean() throws IOException {
    goTo(BOOLEAN);
    return bool;
  }

  /** Reads a null value */
  public void getNull() throws IOException {
    goTo(NULL);
  }

  /**
   * @return the current nesting level, the number of parent objects or arrays.
   */
  public int getLevel() {
    return ptr;
  }

  public long getPosition() {
    return gpos + start;
  }
}

/**
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements. See the NOTICE file distributed with this
 * work for additional information regarding copyright ownership. The ASF
 * licenses this file to You under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 * http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations under
 * the License.
 */

// CharArr origins
// V1.0 7/06/97
// V1.1 9/21/99
// V1.2 2/02/04 // Java5 features
// V1.3 11/26/06 // Make safe for Java 1.4, work into Noggit
// @author yonik
// Java5 version could look like the following:
// public class CharArr implements CharSequence, Appendable, Readable, Closeable
// {
/**
 * @author yonik
 * @version $Id: CharArr.java 583538 2007-10-10 16:53:02Z yonik $
 */
class CharArr implements CharSequence, Appendable {
  protected char[] buf;

  protected int start;

  protected int end;

  public CharArr() {
    this(32);
  }

  public CharArr(int size) {
    buf = new char[size];
  }

  public CharArr(char[] arr, int start, int end) {
    set(arr, start, end);
  }

  public void setStart(int start) {
    this.start = start;
  }

  public void setEnd(int end) {
    this.end = end;
  }

  public void set(char[] arr, int start, int end) {
    this.buf = arr;
    this.start = start;
    this.end = end;
  }

  public char[] getArray() {
    return buf;
  }

  public int getStart() {
    return start;
  }

  public int getEnd() {
    return end;
  }

  public int size() {
    return end - start;
  }

  public int length() {
    return size();
  }

  public int capacity() {
    return buf.length;
  }

  public char charAt(int index) {
    return buf[start + index];
  }

  public CharArr subSequence(int start, int end) {
    return new CharArr(buf, this.start + start, this.start + end);
  }

  public int read() throws IOException {
    if (start >= end)
      return -1;
    return buf[start++];
  }

  public int read(char cbuf[], int off, int len) {
    // TODO
    return 0;
  }

  public void unsafeWrite(char b) {
    buf[end++] = b;
  }

  public void unsafeWrite(int b) {
    unsafeWrite((char) b);
  }

  public void unsafeWrite(char b[], int off, int len) {
    System.arraycopy(b, off, buf, end, len);
    end += len;
  }

  protected void resize(int len) {
    char newbuf[] = new char[Math.max(buf.length << 1, len)];
    System.arraycopy(buf, start, newbuf, 0, size());
    buf = newbuf;
  }

  public void reserve(int num) {
    if (end + num > buf.length)
      resize(end + num);
  }

  public void write(char b) {
    if (end >= buf.length) {
      resize(end + 1);
    }
    unsafeWrite(b);
  }

  public final void write(int b) {
    write((char) b);
  }

  public final void write(char[] b) {
    write(b, 0, b.length);
  }

  public void write(char b[], int off, int len) {
    reserve(len);
    unsafeWrite(b, off, len);
  }

  public final void write(CharArr arr) {
    write(arr.buf, start, end - start);
  }

  public final void write(String s) {
    write(s, 0, s.length());
  }

  public void write(String s, int stringOffset, int len) {
    reserve(len);
    s.getChars(stringOffset, len, buf, end);
    end += len;
  }

  public void flush() {
  }

  public final void reset() {
    start = end = 0;
  }

  public void close() {
  }

  public char[] toCharArray() {
    char newbuf[] = new char[size()];
    System.arraycopy(buf, start, newbuf, 0, size());
    return newbuf;
  }

  public String toString() {
    return new String(buf, start, size());
  }

  public int read(CharBuffer cb) throws IOException {

    /***************************************************************************
     * int sz = size(); if (sz<=0) return -1; if (sz>0) cb.put(buf, start, sz);
     * return -1;
     **************************************************************************/

    int sz = size();
    if (sz > 0)
      cb.put(buf, start, sz);
    start = end;
    while (true) {
      fill();
      int s = size();
      if (s == 0)
        return sz == 0 ? -1 : sz;
      sz += s;
      cb.put(buf, start, s);
    }
  }

  public int fill() throws IOException {
    return 0; // or -1?
  }

  // ////////////// Appendable methods /////////////
  public final Appendable append(CharSequence csq) throws IOException {
    return append(csq, 0, csq.length());
  }

  public Appendable append(CharSequence csq, int start, int end) throws IOException {
    write(csq.subSequence(start, end).toString());
    return null;
  }

  public final Appendable append(char c) throws IOException {
    write(c);
    return this;
  }
}

class NullCharArr extends CharArr {
  public NullCharArr() {
    super(new char[1], 0, 0);
  }

  public void unsafeWrite(char b) {
  }

  public void unsafeWrite(char b[], int off, int len) {
  }

  public void unsafeWrite(int b) {
  }

  public void write(char b) {
  }

  public void write(char b[], int off, int len) {
  }

  public void reserve(int num) {
  }

  protected void resize(int len) {
  }

  public Appendable append(CharSequence csq, int start, int end) throws IOException {
    return this;
  }

  public char charAt(int index) {
    return 0;
  }

  public void write(String s, int stringOffset, int len) {
  }
}

// IDEA: a subclass that refills the array from a reader?
class CharArrReader extends CharArr {
  protected final Reader in;

  public CharArrReader(Reader in, int size) {
    super(size);
    this.in = in;
  }

  public int read() throws IOException {
    if (start >= end)
      fill();
    return start >= end ? -1 : buf[start++];
  }

  public int read(CharBuffer cb) throws IOException {
    // empty the buffer and then read direct
    int sz = size();
    if (sz > 0)
      cb.put(buf, start, end);
    int sz2 = in.read(cb);
    if (sz2 >= 0)
      return sz + sz2;
    return sz > 0 ? sz : -1;
  }

  public int fill() throws IOException {
    if (start >= end) {
      reset();
    } else if (start > 0) {
      System.arraycopy(buf, start, buf, 0, size());
      end = size();
      start = 0;
    }
    /***************************************************************************
     * // fill fully or not??? do { int sz = in.read(buf,end,buf.length-end); if
     * (sz==-1) return; end+=sz; } while (end < buf.length);
     **************************************************************************/

    int sz = in.read(buf, end, buf.length - end);
    if (sz > 0)
      end += sz;
    return sz;
  }

}

class CharArrWriter extends CharArr {
  protected Writer sink;

  @Override
  public void flush() {
    try {
      sink.write(buf, start, end - start);
    } catch (IOException e) {
      throw new RuntimeException(e);
    }
    start = end = 0;
  }

  @Override
  public void write(char b) {
    if (end >= buf.length) {
      flush();
    }
    unsafeWrite(b);
  }

  @Override
  public void write(char b[], int off, int len) {
    int space = buf.length - end;
    if (len < space) {
      unsafeWrite(b, off, len);
    } else if (len < buf.length) {
      unsafeWrite(b, off, space);
      flush();
      unsafeWrite(b, off + space, len - space);
    } else {
      flush();
      try {
        sink.write(b, off, len);
      } catch (IOException e) {
        throw new RuntimeException(e);
      }
    }
  }

  @Override
  public void write(String s, int stringOffset, int len) {
    int space = buf.length - end;
    if (len < space) {
      s.getChars(stringOffset, stringOffset + len, buf, end);
      end += len;
    } else if (len < buf.length) {
      // if the data to write is small enough, buffer it.
      s.getChars(stringOffset, stringOffset + space, buf, end);
      flush();
      s.getChars(stringOffset + space, stringOffset + len, buf, 0);
      end = len - space;
    } else {
      flush();
      // don't buffer, just write to sink
      try {
        sink.write(s, stringOffset, len);
      } catch (IOException e) {
        throw new RuntimeException(e);
      }

    }
  }
}

/**
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements. See the NOTICE file distributed with this
 * work for additional information regarding copyright ownership. The ASF
 * licenses this file to You under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 * http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations under
 * the License.
 */

/**
 * @author yonik
 * @version $Id: JSONUtil.java 666240 2008-06-10 18:00:38Z yonik $
 */
class JSONUtil {
  public static final char[] TRUE_CHARS = new char[] { 't', 'r', 'u', 'e' };

  public static final char[] FALSE_CHARS = new char[] { 'f', 'a', 'l', 's', 'e' };

  public static final char[] NULL_CHARS = new char[] { 'n', 'u', 'l', 'l' };

  public static final char[] HEX_CHARS = new char[] { '0', '1', '2', '3', '4', '5', '6', '7', '8',
      '9', 'a', 'b', 'c', 'd', 'e', 'f' };

  public static final char VALUE_SEPARATOR = ',';

  public static final char NAME_SEPARATOR = ':';

  public static final char OBJECT_START = '{';

  public static final char OBJECT_END = '}';

  public static final char ARRAY_START = '[';

  public static final char ARRAY_END = ']';

  public static String toJSON(Object o) {
    CharArr out = new CharArr();
    new TextSerializer().serialize(new JSONWriter(out), o);
    return out.toString();

  }

  public static void writeNumber(long number, CharArr out) {
    out.write(Long.toString(number));
  }

  public static void writeNumber(double number, CharArr out) {
    out.write(Double.toString(number));
  }

  public static void writeString(CharArr val, CharArr out) {
    writeString(val.getArray(), val.getStart(), val.getEnd(), out);
  }

  public static void writeString(char[] val, int start, int end, CharArr out) {
    out.write('"');
    writeStringPart(val, start, end, out);
    out.write('"');
  }

  public static void writeString(CharSequence val, int start, int end, CharArr out) {
    out.write('"');
    writeStringPart(val, start, end, out);
    out.write('"');
  }

  public static void writeStringPart(char[] val, int start, int end, CharArr out) {
    for (int i = start; i < end; i++) {
      char ch = val[i];
      switch (ch) {
      case '"':
      case '\\':
        out.write('\\');
        out.write(ch);
        break;
      case '\r':
        out.write('\\');
        out.write('r');
        break;
      case '\n':
        out.write('\\');
        out.write('n');
        break;
      case '\t':
        out.write('\\');
        out.write('t');
        break;
      case '\b':
        out.write('\\');
        out.write('b');
        break;
      case '\f':
        out.write('\\');
        out.write('f');
        break;
      // case '/':
      default:
        if (ch <= 0x1F) {
          unicodeEscape(ch, out);
        } else {
          out.write(ch);
        }
      }
    }
  }

  public static void writeStringPart(CharSequence chars, int start, int end, CharArr out) {
    for (int i = start; i < end; i++) {
      char ch = chars.charAt(i);
      switch (ch) {
      case '"':
      case '\\':
        out.write('\\');
        out.write(ch);
        break;
      case '\r':
        out.write('\\');
        out.write('r');
        break;
      case '\n':
        out.write('\\');
        out.write('n');
        break;
      case '\t':
        out.write('\\');
        out.write('t');
        break;
      case '\b':
        out.write('\\');
        out.write('b');
        break;
      case '\f':
        out.write('\\');
        out.write('f');
        break;
      // case '/':
      default:
        if (ch <= 0x1F) {
          unicodeEscape(ch, out);
        } else {
          out.write(ch);
        }
      }
    }
  }

  public static void unicodeEscape(int ch, CharArr out) {
    out.write('\\');
    out.write('u');
    out.write(HEX_CHARS[ch >>> 12]);
    out.write(HEX_CHARS[(ch >>> 8) & 0xf]);
    out.write(HEX_CHARS[(ch >>> 4) & 0xf]);
    out.write(HEX_CHARS[ch & 0xf]);
  }

  public static void writeNull(CharArr out) {
    out.write(NULL_CHARS);
  }

  public static void writeBoolean(boolean val, CharArr out) {
    out.write(val ? TRUE_CHARS : FALSE_CHARS);
  }

}

/**
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements. See the NOTICE file distributed with this
 * work for additional information regarding copyright ownership. The ASF
 * licenses this file to You under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 * http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations under
 * the License.
 */

class TextSerializer {
  public void serialize(TextWriter writer, Map val) {
    writer.startObject();
    boolean first = true;
    for (Map.Entry entry : (Set<Map.Entry>) val.entrySet()) {
      if (first) {
        first = false;
      } else {
        writer.writeValueSeparator();
      }
      writer.writeString(entry.getKey().toString());
      writer.writeNameSeparator();
      serialize(writer, entry.getValue());
    }
    writer.endObject();
  }

  public void serialize(TextWriter writer, Collection val) {
    writer.startArray();
    boolean first = true;
    for (Object o : val) {
      if (first) {
        first = false;
      } else {
        writer.writeValueSeparator();
      }
      serialize(writer, o);
    }
    writer.endArray();
  }

  public void serialize(TextWriter writer, Object o) {
    if (o == null) {
      writer.writeNull();
    } else if (o instanceof CharSequence) {
      writer.writeString((CharSequence) o);
    } else if (o instanceof Number) {
      if (o instanceof Integer || o instanceof Long) {
        writer.write(((Number) o).longValue());
      } else if (o instanceof Float || o instanceof Double) {
        writer.write(((Number) o).doubleValue());
      } else {
        CharArr arr = new CharArr();
        arr.write(o.toString());
        writer.writeNumber(arr);
      }
    } else if (o instanceof Map) {
      this.serialize(writer, (Map) o);
    } else if (o instanceof Collection) {
      this.serialize(writer, (Collection) o);
    } else if (o instanceof Object[]) {
      this.serialize(writer, Arrays.asList(o));
    } else {
      writer.writeString(o.toString());
    }
  }
}

/**
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements. See the NOTICE file distributed with this
 * work for additional information regarding copyright ownership. The ASF
 * licenses this file to You under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 * http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations under
 * the License.
 */

/**
 * @author yonik
 * @version $Id: TextWriter.java 666240 2008-06-10 18:00:38Z yonik $
 */
abstract class TextWriter {
  public abstract void writeNull();

  public abstract void writeString(CharSequence str);

  public abstract void writeString(CharArr str);

  public abstract void writeStringStart();

  public abstract void writeStringChars(CharArr partialStr);

  public abstract void writeStringEnd();

  public abstract void write(long number);

  public abstract void write(double number);

  public abstract void write(boolean bool);

  public abstract void writeNumber(CharArr digits);

  public abstract void writePartialNumber(CharArr digits);

  public abstract void startObject();

  public abstract void endObject();

  public abstract void startArray();

  public abstract void endArray();

  public abstract void writeValueSeparator();

  public abstract void writeNameSeparator();

  // void writeNameValue(String name, Object val)?
}

/**
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements. See the NOTICE file distributed with this
 * work for additional information regarding copyright ownership. The ASF
 * licenses this file to You under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 * http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations under
 * the License.
 */

/**
 * @author yonik
 * @version $Id: JSONWriter.java 666240 2008-06-10 18:00:38Z yonik $
 */

// how to couple with JSONParser to allow streaming large values from input to
// output?
// IDEA 1) have JSONParser.getString(JSONWriter out)?
// IDEA 2) have an output CharArr that acts as a filter to escape data
// IDEA: a subclass of JSONWriter could provide more state and stricter checking
class JSONWriter extends TextWriter {
  int level;

  boolean doIndent;

  final CharArr out;

  JSONWriter(CharArr out) {
    this.out = out;
  }

  public void writeNull() {
    JSONUtil.writeNull(out);
  }

  public void writeString(CharSequence str) {
    JSONUtil.writeString(str, 0, str.length(), out);
  }

  public void writeString(CharArr str) {
    JSONUtil.writeString(str, out);
  }

  public void writeStringStart() {
    out.write('"');
  }

  public void writeStringChars(CharArr partialStr) {
    JSONUtil
        .writeStringPart(partialStr.getArray(), partialStr.getStart(), partialStr.getEnd(), out);
  }

  public void writeStringEnd() {
    out.write('"');
  }

  public void write(long number) {
    JSONUtil.writeNumber(number, out);
  }

  public void write(double number) {
    JSONUtil.writeNumber(number, out);
  }

  public void write(boolean bool) {
    JSONUtil.writeBoolean(bool, out);
  }

  public void writeNumber(CharArr digits) {
    out.write(digits);
  }

  public void writePartialNumber(CharArr digits) {
    out.write(digits);
  }

  public void startObject() {
    out.write('{');
    level++;
  }

  public void endObject() {
    out.write('}');
    level--;
  }

  public void startArray() {
    out.write('[');
    level++;
  }

  public void endArray() {
    out.write(']');
    level--;
  }

  public void writeValueSeparator() {
    out.write(',');
  }

  public void writeNameSeparator() {
    out.write(':');
  }

}
////////////////////////////////////////
/**
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package org.apache.noggit;

import junit.framework.TestCase;

import java.util.Random;
import java.io.StringReader;
import java.io.IOException;

/**
 * @author yonik
 * @version $Id: TestJSONParser.java 583538 2007-10-10 16:53:02Z yonik $
 */
public class TestJSONParser extends TestCase {

  public static Random r = new Random(0);

  public static JSONParser getParser(String s) {
    return getParser(s, r.nextInt(2));
  }
  
  public static JSONParser getParser(String s, int type) {
    JSONParser parser=null;
    switch (type) {
      case 0:
        // test directly using input buffer
        parser = new JSONParser(s.toCharArray(),0,s.length());
        break;
      case 1:
        // test using Reader...
        // small input buffers can help find bugs on boundary conditions
        parser = new JSONParser(new StringReader(s), new char[r.nextInt(25)+1]);
        break;
    }
    return parser;
  }

  public static byte[] events = new byte[256];
  static {
    events['{'] = JSONParser.OBJECT_START;
    events['}'] = JSONParser.OBJECT_END;
    events['['] = JSONParser.ARRAY_START;
    events[']'] = JSONParser.ARRAY_END;
    events['s'] = JSONParser.STRING;
    events['b'] = JSONParser.BOOLEAN;
    events['l'] = JSONParser.LONG;
    events['n'] = JSONParser.NUMBER;
    events['N'] = JSONParser.BIGNUMBER;
    events['0'] = JSONParser.NULL;
    events['e'] = JSONParser.EOF;
  }

  // match parser states with the expected states
  public static void parse(JSONParser p, String input, String expected) throws IOException {
    expected += "e";
    for (int i=0; i<expected.length(); i++) {
      int ev = p.nextEvent();
      int expect = events[expected.charAt(i)];
      if (ev != expect) {
        TestCase.fail("Expected " + expect + ", got " + ev
                + "\n\tINPUT=" + input
                + "\n\tEXPECTED=" + expected
                + "\n\tAT=" + i + " ("+ expected.charAt(i) + ")");
      }
    }
  }

  public static void parse(String input, String expected) throws IOException {
    input = input.replace('\'','"');
    for (int i=0; i<Integer.MAX_VALUE; i++) {
      JSONParser p = getParser(input,i);
      if (p==null) break;
      parse(p,input,expected);
    }    
  }


  
  public static class Num {
    public String digits;
    public Num(String digits) {
      this.digits = digits;
    }
    public String toString() { return new String("NUMBERSTRING("+digits+")"); }
    public boolean equals(Object o) {
      return (getClass()==o.getClass() && digits.equals(((Num)o).digits));
    }
  }

  public static class BigNum extends Num {
    public String toString() { return new String("BIGNUM("+digits+")"); }    
    public BigNum(String digits) { super(digits); }
  }

  // Oh, what I wouldn't give for Java5 varargs and autoboxing
  public static Long o(int l) { return new Long(l); }
  public static Long o(long l) { return new Long(l); }
  public static Double o(double d) { return new Double(d); }
  public static Boolean o(boolean b) { return new Boolean(b); }
  public static Num n(String digits) { return new Num(digits); }
  public static Num bn(String digits) { return new BigNum(digits); }
  public static Object t = new Boolean(true);
  public static Object f = new Boolean(false);
  public static Object a = new Object(){public String toString() {return "ARRAY_START";}};
  public static Object A = new Object(){public String toString() {return "ARRAY_END";}};
  public static Object m = new Object(){public String toString() {return "OBJECT_START";}};
  public static Object M = new Object(){public String toString() {return "OBJECT_END";}};
  public static Object N = new Object(){public String toString() {return "NULL";}};
  public static Object e = new Object(){public String toString() {return "EOF";}};

  // match parser states with the expected states
  public static void parse(JSONParser p, String input, Object[] expected) throws IOException {
    for (int i=0; i<expected.length; i++) {
      int ev = p.nextEvent();
      Object exp = expected[i];
      Object got = null;

      switch(ev) {
        case JSONParser.ARRAY_START: got=a; break;
        case JSONParser.ARRAY_END: got=A; break;
        case JSONParser.OBJECT_START: got=m; break;
        case JSONParser.OBJECT_END: got=M; break;
        case JSONParser.LONG: got=o(p.getLong()); break;
        case JSONParser.NUMBER:
          if (exp instanceof Double) {
            got = o(p.getDouble());
          } else {
            got = n(p.getNumberChars().toString());
          }
          break;
        case JSONParser.BIGNUMBER: got=bn(p.getNumberChars().toString()); break;
        case JSONParser.NULL: got=N; p.getNull(); break; // optional
        case JSONParser.BOOLEAN: got=o(p.getBoolean()); break;
        case JSONParser.EOF: got=e; break;
        case JSONParser.STRING: got=p.getString(); break;
        default: got="Unexpected Event Number " + ev;
      }

      if (!(exp==got || exp.equals(got))) {
        TestCase.fail("Fail: String='"+input+"'"
                + "\n\tINPUT=" + got
                + "\n\tEXPECTED=" + exp
                + "\n\tAT RULE " + i);
      }
    }
  }


  public static void parse(String input, Object[] expected) throws IOException {
    input = input.replace('\'','"');
    for (int i=0; i<Integer.MAX_VALUE; i++) {
      JSONParser p = getParser(input,i);
      if (p==null) break;
      parse(p,input,expected);
    }
  }




  public static void err(String input) throws IOException {
    try {
      JSONParser p = getParser(input);
      while (p.nextEvent() != JSONParser.EOF);
    } catch (Exception e) {
      return;
    }
    TestCase.fail("Input should failed:'" + input + "'");    
  }

  public void testNull() throws IOException {
    err("[nullz]");
    parse("[null]","[0]");
    parse("{'hi':null}",new Object[]{m,"hi",N,M,e});
  }

  public void testBool() throws IOException {
    err("[True]");
    err("[False]");
    err("[TRUE]");
    err("[FALSE]");
    err("[truex]");
    err("[falsex]"); 

    parse("[false,true, false , true ]",new Object[]{a,f,t,f,t,A,e});
  }

  public void testString() throws IOException {
    // NOTE: single quotes are converted to double quotes by this
    // testsuite!
    err("[']");
    err("[',]");
    err("{'}");
    err("{',}");

    err("['\\u111']");
    err("['\\u11']");
    err("['\\u1']");
    err("['\\']");
    err("['\\ ']");
    err("['\\U1111']");


    parse("['']",new Object[]{a,"",A,e});
    parse("['\\\\']",new Object[]{a,"\\",A,e});
    parse("['X\\\\']",new Object[]{a,"X\\",A,e});
    parse("['\\\\X']",new Object[]{a,"\\X",A,e});
    parse("['\\'']",new Object[]{a,"\"",A,e});


    String esc="\\n\\r\\tX\\b\\f\\/\\\\X\\\"";
    String exp="\n\r\tX\b\f/\\X\"";
    parse("['" + esc + "']",new Object[]{a,exp,A,e});
    parse("['" + esc+esc+esc+esc+esc + "']",new Object[]{a,exp+exp+exp+exp+exp,A,e});

    esc="\\u004A";
    exp="\u004A";
    parse("['" + esc + "']",new Object[]{a,exp,A,e});

    esc="\\u0000\\u1111\\u2222\\u12AF\\u12BC\\u19DE";
    exp="\u0000\u1111\u2222\u12AF\u12BC\u19DE";
    parse("['" + esc + "']",new Object[]{a,exp,A,e});

  }

  public void testNumbers() throws IOException {
    err("[00]");
    err("[003]");
    err("[00.3]");
    err("[1e1.1]");
    err("[+1]");
    err("[NaN]");
    err("[Infinity]");
    err("[--1]");


    String lmin    = "-9223372036854775808";
    String lminNot = "-9223372036854775809";
    String lmax    = "9223372036854775807";
    String lmaxNot = "9223372036854775808";

    String bignum="12345678987654321357975312468642099775533112244668800152637485960987654321";

    parse("[0,1,-1,543,-876]", new Object[]{a,o(0),o(1),o(-1),o(543),o(-876),A,e});
    parse("[-0]",new Object[]{a,o(0),A,e});


    parse("["+lmin +"," + lmax+"]",
          new Object[]{a,o(Long.MIN_VALUE),o(Long.MAX_VALUE),A,e});

    parse("["+bignum+"]", new Object[]{a,bn(bignum),A,e});
    parse("["+"-"+bignum+"]", new Object[]{a,bn("-"+bignum),A,e});

    parse("["+lminNot+"]",new Object[]{a,bn(lminNot),A,e});
    parse("["+lmaxNot+"]",new Object[]{a,bn(lmaxNot),A,e});

    parse("["+lminNot + "," + lmaxNot + "]",
          new Object[]{a,bn(lminNot),bn(lmaxNot),A,e});

    // bignum many digits on either side of decimal
    String t = bignum + "." + bignum;
    parse("["+t+","+"-"+t+"]", new Object[]{a,bn(t),bn("-"+t),A,e});
    err(t+".1"); // extra decimal
    err("-"+t+".1");

    // bignum exponent w/o fraction
    t = "1" + "e+" + bignum;
    parse("["+t+","+"-"+t+"]", new Object[]{a,bn(t),bn("-"+t),A,e});
    t = "1" + "E+" + bignum;
    parse("["+t+","+"-"+t+"]", new Object[]{a,bn(t),bn("-"+t),A,e});
    t = "1" + "e" + bignum;
    parse("["+t+","+"-"+t+"]", new Object[]{a,bn(t),bn("-"+t),A,e});
    t = "1" + "E" + bignum;
    parse("["+t+","+"-"+t+"]", new Object[]{a,bn(t),bn("-"+t),A,e});
    t = "1" + "e-" + bignum;
    parse("["+t+","+"-"+t+"]", new Object[]{a,bn(t),bn("-"+t),A,e});
    t = "1" + "E-" + bignum;
    parse("["+t+","+"-"+t+"]", new Object[]{a,bn(t),bn("-"+t),A,e});

    t = bignum + "e+" + bignum;
    parse("["+t+","+"-"+t+"]", new Object[]{a,bn(t),bn("-"+t),A,e});
    t = bignum + "E-" + bignum;
    parse("["+t+","+"-"+t+"]", new Object[]{a,bn(t),bn("-"+t),A,e});
    t = bignum + "e" + bignum;
    parse("["+t+","+"-"+t+"]", new Object[]{a,bn(t),bn("-"+t),A,e});

    t = bignum + "." + bignum + "e" + bignum;
    parse("["+t+","+"-"+t+"]", new Object[]{a,bn(t),bn("-"+t),A,e});

    err("[1E]");
    err("[1E-]");
    err("[1E+]");
    err("[1E+.3]");
    err("[1E+0.3]");
    err("[1E+1e+3]");
    err("["+bignum+"e"+"]");
    err("["+bignum+"e-"+"]");
    err("["+bignum+"e+"+"]");
    err("["+bignum+"."+bignum+"."+bignum+"]");


    double[] vals = new double[] {0,0.1,1.1,
            Double.MAX_VALUE,
            Double.MIN_VALUE,
            2.2250738585072014E-308, /* Double.MIN_NORMAL */
    };
    for (int i=0; i<vals.length; i++) {
      double d = vals[i];
      parse("["+d+","+-d+"]", new Object[]{a,o(d),o(-d),A,e});      
    }

    // MIN_NORMAL has the max number of digits (23), so check that
    // adding an extra digit causes BIGNUM to be returned.
    t = "2.2250738585072014E-308" + "0";
    parse("["+t+","+"-"+t+"]", new Object[]{a,bn(t),bn("-"+t),A,e});
    // check it works with a leading zero too
    t = "0.2250738585072014E-308" + "0";
    parse("["+t+","+"-"+t+"]", new Object[]{a,bn(t),bn("-"+t),A,e});
  }

  public void testArray() throws IOException {
    parse("[]","[]");
    parse("[ ]","[]");
    parse(" \r\n\t[\r\t\n ]\r\n\t ","[]");

    parse("[0]","[l]");
    parse("['0']","[s]");
    parse("[0,'0',0.1]","[lsn]");

    parse("[[[[[]]]]]","[[[[[]]]]]");
    parse("[[[[[0]]]]]","[[[[[l]]]]]");

    err("]");
    err("[");
    err("[[]");
    err("[]]");
    err("[}");
    err("{]");
    err("['a':'b']");
  }

  public void testObject() throws IOException {
    parse("{}","{}");
    parse("{}","{}");
    parse(" \r\n\t{\r\t\n }\r\n\t ","{}");

    parse("{'':null}","{s0}");

    err("}");
    err("[}]");
    err("{");
    err("[{]");
    err("{{}");
    err("[{{}]");
    err("{}}");;
    err("[{}}]");;
    err("{1}");
    err("[{1}]");
    err("{'a'}");
    err("{'a','b'}");
    err("{null:'b'}");
    err("{[]:'b'}");
    err("{true:'b'}");
    err("{false:'b'}");
    err("{{'a':'b'}:'c'}");

    parse("{"+"}", new Object[]{m,M,e});
    parse("{'a':'b'}", new Object[]{m,"a","b",M,e});
    parse("{'a':5}", new Object[]{m,"a",o(5),M,e});
    parse("{'a':null}", new Object[]{m,"a",N,M,e});
    parse("{'a':[]}", new Object[]{m,"a",a,A,M,e});
    parse("{'a':{'b':'c'}}", new Object[]{m,"a",m,"b","c",M,M,e});

    String big = "Now is the time for all good men to come to the aid of their country!";
    String t = big+big+big+big+big;
    parse("{'"+t+"':'"+t+"','a':'b'}", new Object[]{m,t,t,"a","b",M,e});
  }



  public void testAPI() throws IOException {
    JSONParser p = new JSONParser("[1,2]");
    assertEquals(JSONParser.ARRAY_START, p.nextEvent());
    // no nextEvent for the next objects...
    assertEquals(1,p.getLong());
    assertEquals(2,p.getLong());
    

  }

}

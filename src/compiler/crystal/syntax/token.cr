require "./location"

module Crystal
  class Token
    property type : Symbol
    property value : Char | String | Symbol | Nil
    property number_kind : NumberKind
    property line_number : Int32
    property column_number : Int32
    property filename : String | VirtualFile | Nil
    property delimiter_state : DelimiterState
    property macro_state : MacroState
    property passed_backslash_newline : Bool
    property doc_buffer : IO::Memory?
    property raw : String
    property start : Int32
    property invalid_escape : Bool

    record MacroState,
      whitespace : Bool,
      nest : Int32,
      control_nest : Int32,
      delimiter_state : DelimiterState?,
      beginning_of_line : Bool,
      yields : Bool,
      comment : Bool,
      heredocs : Array(DelimiterState)? do
      def self.default
        MacroState.new(true, 0, 0, nil, true, false, false, nil)
      end

      setter whitespace
      setter control_nest
    end

    enum DelimiterKind
      STRING
      REGEX
      STRING_ARRAY
      SYMBOL_ARRAY
      COMMAND
      HEREDOC
    end

    record DelimiterState,
      kind : DelimiterKind,
      nest : Char | String,
      end : Char | String,
      open_count : Int32,
      heredoc_indent : Int32,
      allow_escapes : Bool do
    end

    struct DelimiterState
      def self.default
        DelimiterState.new(:string, '\0', '\0', 0, 0, true)
      end

      def self.new(kind : DelimiterKind, nest, the_end)
        new kind, nest, the_end, 0, 0, true
      end

      def self.new(kind : DelimiterKind, nest, the_end, allow_escapes : Bool)
        new kind, nest, the_end, 0, 0, allow_escapes
      end

      def self.new(kind : DelimiterKind, nest, the_end, open_count : Int32)
        new kind, nest, the_end, open_count, 0, true
      end

      def with_open_count_delta(delta)
        DelimiterState.new(@kind, @nest, @end, @open_count + delta, @heredoc_indent, @allow_escapes)
      end

      def with_heredoc_indent(indent)
        DelimiterState.new(@kind, @nest, @end, @open_count, indent, @allow_escapes)
      end
    end

    def initialize
      @type = :EOF
      @number_kind = NumberKind::I32
      @line_number = 0
      @column_number = 0
      @delimiter_state = DelimiterState.default
      @macro_state = MacroState.default
      @passed_backslash_newline = false
      @raw = ""
      @start = 0
      @invalid_escape = false
    end

    def doc
      @doc_buffer.try &.to_s
    end

    @location : Location?

    def location
      @location ||= Location.new(filename, line_number, column_number)
    end

    def location=(@location)
    end

    def token?(token)
      @type == :TOKEN && @value == token
    end

    def keyword?
      @type == :IDENT && @value.is_a?(Symbol)
    end

    def keyword?(keyword)
      @type == :IDENT && @value == keyword
    end

    def copy_from(other)
      @type = other.type
      @value = other.value
      @number_kind = other.number_kind
      @line_number = other.line_number
      @column_number = other.column_number
      @filename = other.filename
      @delimiter_state = other.delimiter_state
      @macro_state = other.macro_state
      @doc_buffer = other.doc_buffer
    end

    def to_s(io : IO) : Nil
      @value ? @value.to_s(io) : @type.to_s(io)
    end
  end
end

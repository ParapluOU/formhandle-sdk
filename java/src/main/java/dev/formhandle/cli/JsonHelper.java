package dev.formhandle.cli;

import java.util.*;
import java.util.regex.*;

/**
 * Minimal JSON parser and formatter. No external dependencies.
 * Handles objects, arrays, strings, numbers, booleans, and null.
 */
public class JsonHelper {

    public static Map<String, Object> parseObject(String json) {
        json = json.trim();
        if (!json.startsWith("{")) {
            return new LinkedHashMap<>();
        }
        return (Map<String, Object>) parse(json, new int[]{0});
    }

    public static String stringify(Object obj, int indent) {
        StringBuilder sb = new StringBuilder();
        write(sb, obj, indent, 0);
        return sb.toString();
    }

    @SuppressWarnings("unchecked")
    private static void write(StringBuilder sb, Object obj, int indent, int depth) {
        if (obj == null) {
            sb.append("null");
        } else if (obj instanceof Map) {
            Map<String, Object> map = (Map<String, Object>) obj;
            if (map.isEmpty()) {
                sb.append("{}");
                return;
            }
            sb.append("{\n");
            int i = 0;
            for (Map.Entry<String, Object> entry : map.entrySet()) {
                sb.append(spaces(indent, depth + 1));
                sb.append('"').append(escape(entry.getKey())).append("\": ");
                write(sb, entry.getValue(), indent, depth + 1);
                if (i < map.size() - 1) sb.append(',');
                sb.append('\n');
                i++;
            }
            sb.append(spaces(indent, depth)).append('}');
        } else if (obj instanceof List) {
            List<Object> list = (List<Object>) obj;
            if (list.isEmpty()) {
                sb.append("[]");
                return;
            }
            sb.append("[\n");
            for (int i = 0; i < list.size(); i++) {
                sb.append(spaces(indent, depth + 1));
                write(sb, list.get(i), indent, depth + 1);
                if (i < list.size() - 1) sb.append(',');
                sb.append('\n');
            }
            sb.append(spaces(indent, depth)).append(']');
        } else if (obj instanceof String) {
            sb.append('"').append(escape((String) obj)).append('"');
        } else if (obj instanceof Number) {
            double d = ((Number) obj).doubleValue();
            if (d == Math.floor(d) && !Double.isInfinite(d)) {
                sb.append((long) d);
            } else {
                sb.append(d);
            }
        } else if (obj instanceof Boolean) {
            sb.append(obj.toString());
        } else {
            sb.append('"').append(escape(obj.toString())).append('"');
        }
    }

    private static String spaces(int indent, int depth) {
        return " ".repeat(indent * depth);
    }

    private static String escape(String s) {
        return s.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r")
                .replace("\t", "\\t");
    }

    // Simple recursive descent parser
    private static Object parse(String s, int[] pos) {
        skipWhitespace(s, pos);
        if (pos[0] >= s.length()) return null;
        char c = s.charAt(pos[0]);
        if (c == '{') return parseObj(s, pos);
        if (c == '[') return parseArr(s, pos);
        if (c == '"') return parseStr(s, pos);
        if (c == 't' || c == 'f') return parseBool(s, pos);
        if (c == 'n') return parseNull(s, pos);
        return parseNum(s, pos);
    }

    private static Map<String, Object> parseObj(String s, int[] pos) {
        Map<String, Object> map = new LinkedHashMap<>();
        pos[0]++; // skip {
        skipWhitespace(s, pos);
        if (pos[0] < s.length() && s.charAt(pos[0]) == '}') {
            pos[0]++;
            return map;
        }
        while (pos[0] < s.length()) {
            skipWhitespace(s, pos);
            String key = parseStr(s, pos);
            skipWhitespace(s, pos);
            if (pos[0] < s.length() && s.charAt(pos[0]) == ':') pos[0]++;
            skipWhitespace(s, pos);
            Object val = parse(s, pos);
            map.put(key, val);
            skipWhitespace(s, pos);
            if (pos[0] < s.length() && s.charAt(pos[0]) == ',') {
                pos[0]++;
            } else {
                break;
            }
        }
        if (pos[0] < s.length() && s.charAt(pos[0]) == '}') pos[0]++;
        return map;
    }

    private static List<Object> parseArr(String s, int[] pos) {
        List<Object> list = new ArrayList<>();
        pos[0]++; // skip [
        skipWhitespace(s, pos);
        if (pos[0] < s.length() && s.charAt(pos[0]) == ']') {
            pos[0]++;
            return list;
        }
        while (pos[0] < s.length()) {
            skipWhitespace(s, pos);
            list.add(parse(s, pos));
            skipWhitespace(s, pos);
            if (pos[0] < s.length() && s.charAt(pos[0]) == ',') {
                pos[0]++;
            } else {
                break;
            }
        }
        if (pos[0] < s.length() && s.charAt(pos[0]) == ']') pos[0]++;
        return list;
    }

    private static String parseStr(String s, int[] pos) {
        pos[0]++; // skip opening "
        StringBuilder sb = new StringBuilder();
        while (pos[0] < s.length()) {
            char c = s.charAt(pos[0]);
            if (c == '\\' && pos[0] + 1 < s.length()) {
                pos[0]++;
                char next = s.charAt(pos[0]);
                switch (next) {
                    case '"': sb.append('"'); break;
                    case '\\': sb.append('\\'); break;
                    case 'n': sb.append('\n'); break;
                    case 'r': sb.append('\r'); break;
                    case 't': sb.append('\t'); break;
                    case '/': sb.append('/'); break;
                    default: sb.append('\\').append(next);
                }
            } else if (c == '"') {
                pos[0]++;
                return sb.toString();
            } else {
                sb.append(c);
            }
            pos[0]++;
        }
        return sb.toString();
    }

    private static Number parseNum(String s, int[] pos) {
        int start = pos[0];
        while (pos[0] < s.length() && "0123456789.-+eE".indexOf(s.charAt(pos[0])) >= 0) {
            pos[0]++;
        }
        String num = s.substring(start, pos[0]);
        if (num.contains(".") || num.contains("e") || num.contains("E")) {
            return Double.parseDouble(num);
        }
        return Long.parseLong(num);
    }

    private static Boolean parseBool(String s, int[] pos) {
        if (s.startsWith("true", pos[0])) {
            pos[0] += 4;
            return true;
        }
        pos[0] += 5;
        return false;
    }

    private static Object parseNull(String s, int[] pos) {
        pos[0] += 4;
        return null;
    }

    private static void skipWhitespace(String s, int[] pos) {
        while (pos[0] < s.length() && Character.isWhitespace(s.charAt(pos[0]))) {
            pos[0]++;
        }
    }
}

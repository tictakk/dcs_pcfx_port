#(c) 2022 David Shadoff
# ported & modified by Matthew Kersey
import Bitwise

# Notes:
#
# This program converts a Wonderswan Color RGB palette entry into a PC-FX palette number
#
#   Usage: rgb2yuv <wsc Palette val>
#   OR:    rgb2yuv rgb2yuv <green> <red> <blue>
#   where R,G,B values are 0-15 (and wsc palette val is maximum 9 bits)
#
#   Example:
#     elixir rgb2yuv.exs 15 0 0
#

#
# hexdecode: Get a value and convert it if it has a hexadecimal prefix
#

hexdecode = fn(input) ->  
  case input do
    "0x" <> n = input -> 
                    {d,_} = Integer.parse(n,16)
                    d

    _                 -> 
                    String.to_integer(input)
  end
end

combine_values = fn(x,y) -> (x &&& 0xFF) + (y <<< 8) end

[blue,red,green] = case System.argv do
  [r,g,b]   -> [hexdecode.(r),hexdecode.(g),hexdecode.(b)]

  [h1,h2]   -> num = combine_values.(hexdecode.(h1),hexdecode.(h2))
               [(num &&& 15),((num >>> 4) &&& 15),((num >>> 8) &&& 15)]
               
  [single]  -> num = hexdecode.(single)
               [(num &&& 15),((num >>> 4) &&& 15),((num >>> 8) &&& 15)]

  _         -> raise ArgumentError, message: "incorrect argument count, expects 1, 2 or 3 arguments"
end

IO.puts "Green #{green}"
IO.puts "Red #{red}"
IO.puts "Blue #{blue}"

g = green * 16
r = red * 16
b = blue * 16

yfloat = (0.2990*r) + (0.5870*g) + (0.1140*b)
y = trunc(yfloat)
ufloat = (-0.1686*r) + (-0.3311*g) + (0.4997*b) + 128
u = trunc((ufloat+0.5))>>>4
vfloat = (0.4998*r) + (-0.4185*g) + (-0.0813*b) + 128
v = trunc((vfloat+0.5))>>>4

IO.puts "Y = #{yfloat}"
IO.puts "U = #{ufloat}"
IO.puts "V = #{vfloat}"

yuv = (y*256) + (u*16) + (v)

IO.puts "0x"<>Integer.to_string(yuv,16)
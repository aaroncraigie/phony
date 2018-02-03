# -*- coding: utf-8 -*-
# All countries, ordered by country code.
#
# Definitions are in the format:
#   NDC >> National | NDC >> National | # ...
#
# As soon as a NDC matches, it goes on to the National part. Then breaks off.
# If the NDC does not match, it go on to the next (|, or "or") NDC.
#
# For the pre-ndc part, there's:
# * trunk: If the country has a trunk code (options normalize/split – remove trunk on these method, default false).
#
# Available matching/splitting methods:
# * none:   Does not have a national destination code, e.g. Denmark, Iceland.
# * one_of: Matches one of the following numbers. Splits if it does.
# * match: Try to match the regex, and if it matches, splits it off.
# * fixed:  Always splits off a fixed length ndc. (Always use last in a | chain as a catchall)
#
# For the national number part, there are two:
# * split:         Use this number group splitting.
# * matched_split: Give a hash of regex => format array, with a :fallback => format option.
#                   (See Norway how it looks.)
#
# Note: The ones that are commented are defined in their special files.
#
# @example Switzerland (simplified)
#   country('41', fixed(2) >> local([3,2,2]))
#
# @example Germany. Too big, we use a separate file
#   Phony.define do
#     country '49', match(...) >> split([...]) ||
#                   one_of([...], :max_length => 5) >> split([...])
#   end
#
# @example Denmark
#   country('45', none >> split([2,2,2,2]))
#
# @example Hungary
#   country('36',
#           match(/^104|105|107|112/) >> split([3,3]) ||
#           one_of([1], :max_length => 2) >> split([3,4])
#   )
#
Phony.define do

  # Reserved.
  #
  reserved '0'

  # USA, Canada, etc.
  #
  country '1',
    # The US has a delimiter between NDC and local number.
    trunk('1%s', normalize: true, format: false) | # http://en.wikipedia.org/wiki/Trunk_prefix
    fixed(3) >> split(3,4),
    :invalid_ndcs => /[0-1]\d{2}|[3-9]11/,
    :parentheses => true,
    :local_space => :-

  # Greece. http://www.numberingplans.com/?page=dialling&sub=areacodes
  # https://www.numberingplans.com/?page=plans&sub=phonenr&alpha_2_input=GR
  country '30',
    trunk('0') |
    one_of(%w(231 241 251 261 271 281)) >> split(3,4) |
    one_of('800') >> split(3,4) | # freephone
    one_of(%w(801 807)) >> split(3,4) | # shared cost, premium rate
    one_of('896') >> split(3,4) | # ISP
    one_of(%w(901 909)) >> split(3,4) | # premium rate
    one_of(%w(21 22 23 24 25 26 27 28)) >> split(4,4) |
    one_of('50') >> split(4,4) | # VPN
    match(/^(69\d)\d+$/) >> split(3,4) | # mobile, pager
    one_of('70') >> split(4,4) | # universal access
    fixed(4) >> split(6)   # 3-digit NDCs

  # country '31' # Netherlands, see special file.

  # Belgium.
  #
  # http://en.wikipedia.org/wiki/Telephone_numbers_in_Belgium
  #
  country '32', trunk('0') |
                match(/^(7[08])\d+$/)       >> split(3,3)   | # Premium and national rate Services
                match(/^(800|90\d)\d+$/)    >> split(2,3)   | # Toll free service and premium numbers
                match(/^(46[05678])\d{6}$/) >> split(2,2,2) | # Mobile (Lycamobile, Telenet, Join Experience, Proximus 0460)
                match(/^(4[789]\d)\d{6}$/)  >> split(2,2,2) | # Mobile
                match(/^(456)\d{6}$/)       >> split(2,2,2) | # Mobile Vikings
                one_of('2','3','4','9')     >> split(3,2,2) | # Short NDCs
                fixed(2)                    >> split(2,2,2)   # 2-digit NDCs

  # France.
  #
  country '33',
    trunk('0') |
    fixed(1) >> split(2,2,2,2) # :service? => /^8.*$/, :mobile? => /^[67].*$/

  # Spain.
  #
  # http://www.minetur.gob.es/telecomunicaciones/es-es/servicios/numeracion/paginas/plan.aspx
  #
  country '34',
    match(/^([67]\d{2})\d+$/) >> split(3,3)   | # Mobile
    match(/^([89]0\d)\d+$/)   >> split(3,3)   | # Special 80X & 90X numbers
    one_of(%w(91 93))         >> split(3,2,2) | # Landline large regions
    match(/^(9\d{2})\d+$/)    >> split(2,2,2) | # Landline
    fixed(3, :zero => false)  >> split(3,3)

  # Switzerland.
  #
  country '41',
          trunk('0', normalize: true) |
          match(/^(8(?:00|4[0248]))\d+$/) >> split(3,3) |  # Freecall/Shared Cost
          match(/^(90[016])\d+$/)       >> split(3,3) |  # Business
          fixed(2)                      >> split(3,2,2)

  # Australia.
  #
  country '61',
    trunk('0', format: false) |
    match(/^(4\d\d)\d+$/) >> split(3,3) | # Mobile
    match(/^(1800)\d+$/)  >> split(3,3) | # 1800 free call
    match(/^(1300)\d+$/)  >> split(3,3) | # 1300 local rate
    match(/^(13)\d+$/)    >> split(2,2) | # 13 local rate
    fixed(1)              >> split(4,4)   # Rest

  # New Zealand.
  #
  country '64',
    trunk('0') |
    match(/^(2\d)\d{7}$/) >> split(3,4)   | # Mobile
    match(/^(2\d)\d{6}$/) >> split(3,3)   |
    match(/^(2\d)\d{8}$/) >> split(2,3,3) |
    match(/^(800)\d{6}$/) >> split(3,3)   | # International 800 service where agreed
    match(/^(800)\d{7}$/) >> split(3,4)   | # International 800 service where agreed
    fixed(1) >> split(3,4)                  # Rest

  # Gibraltar
  country '350',
          match(/^(2[012]\d)\d+$/) >> split(5) | # fixed
          match(/^([56]\d)\d+$/) >> split(6)   | # mobile
          match(/^(8\d\d\d)$/) >> split(0)

  # Portugal.
  #
  country '351',
          match(/^([78]\d\d)\d+$/) >> split(3,3) | # Service.
          match(/^(9\d)\d+$/)  >> split(3,4)     | # Mobile.
          one_of('21', '22')   >> split(3,4)     | # Lisboa & Porto
          fixed(3)             >> split(3,3)       # 3-digit NDCs

  # Luxembourg
  #
  country '352',
          match(/^(2[467]\d{2})\d{4}$/)       >> split(2,2)     | # 4-digit NDC
          match(/^(6\d[18])\d+$/)             >> split(3,3)     | # mobile
          match(/^(60\d{2})\d{8}$/)           >> split(2,2,2,2) | # mobile machine to machine
          match(/^((2[^467]|[3-9]\d))\d{4}$/) >> split(2,2)     | # 2-digit NDC Regular 6 digits number
          match(/^((2[^467]|[3-9]\d))\d{4}$/) >> split(2,2)     | # 2-digit NDC Regular 6 digits number
          match(/^((2[^467]|[3-9]\d))\d{5}$/) >> split(2,2,1)   | # 2-digit NDC Regular 6 digits number w/ 1 digit extension
          match(/^((2[^467]|[3-9]\d))\d{6}$/) >> split(2,2,2)   | # 2-digit NDC Regular 8 digits number or 6 digits with 2 digits extension
          match(/^((2[^467]|[3-9]\d))\d{7}$/) >> split(2,2,3)   | # 2-digit NDC Regular 6 digits with 4 digits extension
          match(/^((2[^467]|[3-9]\d))\d{8}$/) >> split(2,2,4)   | # 2-digit NDC Regular 6 digits number with 4 digits extension
          match(/^(\d{2})\d{3}$/)             >> split(2,2,1)     # fallback for 5 digit number

  country '376', fixed(1) >> split(5) # Andorra

  # Monaco
  #
  country '377',
          one_of('6')  >> split(2,2,2,2) | # mobile
          fixed(2) >> split(2,2,2)

  # San Marino
  country '378',
          none >> matched_split(
              /\A\d{6}\z/ => [3,3],
              /\A\d+\z/ => [3,3,4]
          )

  country '379', todo # Vatican City State

  country '672', todo # Australian External Territories


end

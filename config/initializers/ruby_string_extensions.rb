class String
  
  Ofac_SoundexChars = 'BPFVCSKGJQXZDTLMNR'
  Ofac_SoundexNums  = '111122222222334556'
  Ofac_SoundexCharsEx = '^' + Ofac_SoundexChars
  Ofac_SoundexCharsDel = '^A-Z'

  # desc: http://en.wikipedia.org/wiki/Soundex
  def ofac_soundex(census = true)
    str = upcase.delete(Ofac_SoundexCharsDel).squeeze

    str[0 .. 0] + str[1 .. -1].
      delete(Ofac_SoundexCharsEx).
      tr(Ofac_SoundexChars, Ofac_SoundexNums)[0 .. (census ? 2 : -1)].
      ljust(3, '0') rescue ''
  end

  def ofac_sounds_like(other, census = true)
    ofac_soundex(census) == other.ofac_soundex(census)
  end

end
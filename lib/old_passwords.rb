module OldPasswords
  # source: https://github.com/joerghaubrichs/Ruby-MySQL-old_password-function
  def encrypt_using_old_password(string)
    nr = 1345345333
    nr2 = 0x12345671
    add = 7

    string.each_char do |char|
        if (char == ' ' or char == '\t')
          next
        end
        tmp = char.ord
        nr ^= (((nr & 63) + add) * tmp) + (nr << 8)
        nr2 += (nr2 << 8) ^ nr
        add += tmp
    end

    res1 = nr & 0x7fffffff
    res2 = nr2 & 0x7fffffff

    '%08x%08x' % [res1, res2]
  end
end

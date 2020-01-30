class Vasmm68k < Formula
  desc "Cross-assembler for 680x0 processors / Amiga OS"
  homepage "http://sun.hasenbraten.de/vasm"
  url "http://sun.hasenbraten.de/vasm/daily/vasm.tar.gz"
  version "1.8f"
  sha256 "d5003590fa493977d3d11c973cefbf33514879a650d51a5ad5b881ba82b1987d"
  version_scheme 1

  head do
    url "http://sun.hasenbraten.de/vasm/daily/vasm.tar.gz"
  end

  def install
    # ENV.deparallelize
    system "(make CPU=m68k SYNTAX=mot && chmod ugo+rx vasmm68k_mot)"
    system "(make CPU=m68k SYNTAX=std && chmod ugo+rx vasmm68k_std)"
    bin.install "vasmm68k_mot"
    bin.install "vasmm68k_std"
    bin.install "vobjdump"
  end

  test do
    require "digest/md5"

    # Verify that vasmm68k_mot can assemble a given file and that the resulting object file has the right content

    (testpath/"test_mot.s").write <<~EOS
      	section	code,code

      main:
      	moveq	#0,d0
      	rts

      	section	data,data

      	dc.l	main
    EOS

    shell_output(["#{bin}/vasmm68k_mot", "-Fhunk", "-o", testpath/"test_mot.o", testpath/"test_mot.s"].join(" "))
    assert_match "46f347f0e0632a53e61130eb7f34f87fc17ffcaf", Digest::SHA1.hexdigest(File.read(testpath/"test_mot.o"))

    # Verify that vasmm68k_std can assemble a given file and that the resulting object file has the right content

    (testpath/"test_std.s").write <<~EOS
      	.section	code

      main:
      	moveq	#0,d0
      	rts

      	.section	data

      	.long	main
    EOS

    shell_output(["#{bin}/vasmm68k_std", "-Fhunk", "-o", testpath/"test_std.o", testpath/"test_std.s"].join(" "))
    assert_match "e06a1c7ade3326f33d1f65b0ebfc57cf27b70e1d", Digest::SHA1.hexdigest(File.read(testpath/"test_std.o"))

    # Verify that vobjdump can decompile a given file and that the resulting text file has the right content

    (testpath/"test_vobjdump.o").write [\
      "564F424A0108044D36386B000203636F64650001030100006461746100010302"\
      "00006D61696E00018400440000010000636F6465006163727800010204000470"\
      "004E75646174610061647277000001040104000000000100002084FFFFFFFF00"\
      "03",
    ].pack("H*")

    (testpath/"test_vobjdump.dis.expected").write [
      "",
      "------------------------------------------------------------------------------",
      "VOBJ M68k (big endian), 8 bits per byte, 4 bytes per word.",
      "3 symbols.",
      "2 sections.",
      "",
      "------------------------------------------------------------------------------",
      '00000030: SECTION "code" (attributes="acrx")',
      "Flags: 1         Alignment: 2      Total size: 4         File size: 4        ",
      "",
      "------------------------------------------------------------------------------",
      '00000043: SECTION "data" (attributes="adrw")',
      "Flags: 0         Alignment: 1      Total size: 4         File size: 4        ",
      "1 Relocation present.",
      "",
      "file offs sectoffs pos sz mask     type     symbol+addend",
      "00000056: 00000000  00 32 ffffffff ABS      main+0",
      "",
      "",
      "------------------------------------------------------------------------------",
      "SYMBOL TABLE",
      "file offs bind size     type def      value    name",
      "0000000e: LOCL 00000000 sect     code        0 code",
      "00000018: LOCL 00000000 sect     data        0 data",
      "00000022: LOCL 00000000          code        0 main",
    ].join("\n") + "\n"

    shell_output(["#{bin}/vobjdump", testpath/"test_vobjdump.o", ">", testpath/"test_vobjdump.dis"].join(" "))
    assert_match Digest::SHA1.hexdigest(File.read(testpath/"test_vobjdump.dis.expected")), Digest::SHA1.hexdigest(File.read(testpath/"test_vobjdump.dis"))
  end
end

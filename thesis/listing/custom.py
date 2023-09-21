import targets

class customHart(targets.Hart):
    xlen = 32
    ram = 0x00000000
    ram_size = 64 * 1024
    instruction_hardware_breakpoint_count = 4
    misa = 0x40000100
    bad_address = 0xA0000000
    reset_vectors = [0x00000000]

class custom(targets.Target):
    harts = [customHart()]
    timeout_sec = 20
    supports_clint_mtime = False
    test_semihosting = False
    support_manual_hwbp = True
    skip_tests = ["Sv32Test","SemihostingFileio","EtriggerTest","IcountTest","TriggerDmode","DownloadTest"]
    support_hasel = False

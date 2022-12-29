#include <stdlib.h>
#include <stdio.h>
#include <stdint.h>
#include <sys/stat.h>

#define TOS "tos404.img"
#define OUT "tos4dfb1.img"

struct bytes { 
    uint32_t addr;
    uint32_t len;
    uint8_t data[];
};
struct file {
    uint32_t addr;
    char *filename;
};

struct bytes change_tos_version = {
    0x000002, // relative to start of image
    2,
    { 0x04, 0x05 }
};

struct bytes jump_to_ttram_detect =  {
    0x00096E, // relative to start of image
    6,
    { 0x4e, 0xb9, 0x00, 0xe7, 0xab, 0x00 }
};
struct bytes skip_crc_check =  {
    0x0006B0, // relative to start of image
    4,
    { 0x60, 0x00, 0x00, 0x94 } // bra $e00746
};



struct file ttram_detect_file = {
    0x07AB00,
    "ttramdetect.img"
};

struct bytes *patchlist[] = { &jump_to_ttram_detect, &skip_crc_check, NULL };
struct file *filelist[] = { &ttram_detect_file, NULL };



int main() {
    struct stat s;
    struct bytes *p;
    struct file *f;
    
    FILE *fptos = fopen( TOS, "rb" );
    FILE *fpout = fopen( OUT, "wb" );
    if( !fptos || !fpout ) {
        fprintf( stderr, "Couldn't open %s or %s\n", TOS, OUT );
        exit(1);
    }
    
    stat( TOS, &s );
    
    uint8_t *tosbytes = malloc( s.st_size );
    if( !tosbytes ) {
        fprintf( stderr, "Couldn't allocate %ld bytes\n", s.st_size );
        exit(2);
    }

    fread( tosbytes, s.st_size, 1, fptos );
    fclose( fptos );
    
    
    for( int i = 0 ; patchlist[i] != NULL ; i++ ) {
        p = patchlist[i];
        printf( "Doing patch %d\n", i+1 );
        for( int j = 0 ; j < p->len ; j++ ) {
            tosbytes[p->addr+j] = p->data[j];
            printf("patching at offset %x\n", p->addr+j );
        }
    }

    for( int i = 0 ; filelist[i] != NULL ; i++ ) {
        f = filelist[i];
        printf( "Doing patchfile %d\n", i+1 );
        
        struct stat fs;
        FILE *fp = fopen( f->filename, "rb" );
        if( !fp ) {
            fprintf( stderr, "Couldn't open patch file %s\n", f->filename );
            exit(3);
        }
        stat( f->filename, &fs );
        uint8_t *patchbytes = malloc( fs.st_size );
        if( !patchbytes ) {
            fprintf( stderr, "Couldn't allocate %ld bytes\n", fs.st_size );
            exit(4);
        }
        fread( patchbytes, fs.st_size, 1, fp );
        fclose( fp );
            
        for( int j = 0 ; j < fs.st_size ; j++ ) {
            tosbytes[f->addr+j] = patchbytes[j];
            printf("patching at offset %x\n", f->addr+j );
        }
    }
    
    
    fwrite( tosbytes, s.st_size, 1, fpout );
    
    fclose(fpout);
    
}

/*
import os

tos = "tos404.img"

outfile = "tos4dfb1.img"

finA = open( tos, "rb" )

infilesizeA = os.stat(tos).st_size

tosbytes = bytearray(finA.read())
finA.close()

fout = open( outfile, "wb" )






#block1.extend( bytearray.fromhex(hex6) )


fout.write(block1)
fout.close()

*/
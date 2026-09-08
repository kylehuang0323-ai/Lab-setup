#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

typedef uint32_t ULONG;
typedef uint8_t UCHAR;
typedef uint16_t USHORT;

typedef struct {
    ULONG Signature;
    ULONG TableLength;
    UCHAR Revision;
    UCHAR Checksum;
    UCHAR OemId[6];
    UCHAR OemTableId[8];
    ULONG OemRevision;
    ULONG CreatorId;
    ULONG CreatorRevision;
} AMD_ACPI_DESCRIPTION_HEADER;

typedef struct {
    AMD_ACPI_DESCRIPTION_HEADER SHeader;
    UCHAR TableUUID[16];
    ULONG VBIOSImageOffset;
    ULONG Lib1ImageOffset;
    ULONG Reserved[4];
} UEFI_ACPI_VFCT;

typedef struct {
    ULONG PCIBus;
    ULONG PCIDevice;
    ULONG PCIFunction;
    USHORT VendorID;
    USHORT DeviceID;
    USHORT SSVID;
    USHORT SSID;
    ULONG Revision;
    ULONG ImageLength;
} VFCT_IMAGE_HEADER;

typedef struct {
    VFCT_IMAGE_HEADER VbiosHeader;
    UCHAR VbiosContent[1];
} GOP_VBIOS_CONTENT;

int main(void) {
    FILE *fp_vfct;
    FILE *fp_vbios;
    UEFI_ACPI_VFCT *pvfct;
    char vbios_name[0x400];

    fp_vfct = fopen("/sys/firmware/acpi/tables/VFCT", "rb");
    if (!fp_vfct) {
        perror("open VFCT");
        return EXIT_FAILURE;
    }

    pvfct = malloc(sizeof(*pvfct));
    if (!pvfct) {
        perror("allocate VFCT header");
        fclose(fp_vfct);
        return EXIT_FAILURE;
    }

    if (fread(pvfct, 1, sizeof(*pvfct), fp_vfct) != sizeof(*pvfct)) {
        fprintf(stderr, "failed to read VFCT header\n");
        free(pvfct);
        fclose(fp_vfct);
        return EXIT_FAILURE;
    }

    ULONG offset = pvfct->VBIOSImageOffset;
    ULONG table_size = pvfct->SHeader.TableLength;

    if (table_size < sizeof(*pvfct) || offset < sizeof(*pvfct) ||
        offset > table_size) {
        fprintf(stderr, "invalid VFCT table size or VBIOS offset\n");
        free(pvfct);
        fclose(fp_vfct);
        return EXIT_FAILURE;
    }

    UEFI_ACPI_VFCT *resized = realloc(pvfct, table_size);
    if (!resized) {
        perror("allocate VFCT table");
        free(pvfct);
        fclose(fp_vfct);
        return EXIT_FAILURE;
    }
    pvfct = resized;

    size_t remaining = table_size - sizeof(*pvfct);
    if (fread(pvfct + 1, 1, remaining, fp_vfct) != remaining) {
        fprintf(stderr, "failed to read VFCT body\n");
        free(pvfct);
        fclose(fp_vfct);
        return EXIT_FAILURE;
    }
    fclose(fp_vfct);

    while (offset <= table_size - sizeof(VFCT_IMAGE_HEADER)) {
        GOP_VBIOS_CONTENT *vbios =
            (GOP_VBIOS_CONTENT *)((char *)pvfct + offset);
        VFCT_IMAGE_HEADER *header = &vbios->VbiosHeader;

        if (!header->ImageLength) {
            break;
        }
        if (header->ImageLength >
            table_size - offset - sizeof(VFCT_IMAGE_HEADER)) {
            fprintf(stderr, "invalid VBIOS image length\n");
            free(pvfct);
            return EXIT_FAILURE;
        }

        snprintf(
            vbios_name,
            sizeof(vbios_name),
            "vbios_%x_%x.bin",
            header->VendorID,
            header->DeviceID
        );

        fp_vbios = fopen(vbios_name, "wb");
        if (!fp_vbios) {
            perror("create VBIOS file");
            free(pvfct);
            return EXIT_FAILURE;
        }

        if (fwrite(
                &vbios->VbiosContent,
                1,
                header->ImageLength,
                fp_vbios
            ) != header->ImageLength) {
            fprintf(stderr, "failed to write %s\n", vbios_name);
            fclose(fp_vbios);
            free(pvfct);
            return EXIT_FAILURE;
        }

        fclose(fp_vbios);
        printf(
            "dump vbios %x:%x to %s\n",
            header->VendorID,
            header->DeviceID,
            vbios_name
        );

        offset += sizeof(VFCT_IMAGE_HEADER) + header->ImageLength;
    }

    free(pvfct);
    return EXIT_SUCCESS;
}

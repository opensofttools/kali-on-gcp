.PHONY: build validate init fmt clean push tarball

PACKER_FILE=templates/kali-rolling.json
BUCKET_NAME=custom-images-for-gce
TARGET_IMAGE_NAME=disk.raw.tar.gz
OUTPUT_DIR=output
IMAGE_NAME=kali-rolling-202403

# ANSI color codes
RED=\033[0;31m
GREEN=\033[0;32m
YELLOW=\033[1;33m
BLUE=\033[0;34m
NC=\033[0m # No Color

# Check if packer is installed
PACKER_CMD=$(shell command -v packer 2> /dev/null)
ifndef PACKER_CMD
$(error "Packer is not installed. Please install it first.")
endif

build:
	@if [ -f $(PACKER_FILE) ]; then \
        echo "${GREEN}Building with Packer...${NC}"; \
        sudo PACKER_LOG=1 packer build --on-error=ask $(PACKER_FILE); \
    else \
        echo "${RED}Packer file $(PACKER_FILE) not found.${NC}"; \
        exit 1; \
    fi

validate:
	@if [ -f $(PACKER_FILE) ]; then \
		echo "${GREEN}Validating Packer template...${NC}"; \
        packer validate $(PACKER_FILE); \
    else \
        echo "${RED}Packer file $(PACKER_FILE) not found.${NC}"; \
        exit 1; \
    fi

init:
	@echo "${GREEN}Initializing Packer...${NC}"
	packer init .

fmt:
	@echo "${GREEN}Formatting Packer template...${NC}"
	@packer fmt .

clean:
	@echo "${YELLOW}Cleaning output directory...${NC}"
	@rm -rf ${OUTPUT_DIR}

push:
	@echo "${GREEN}Pushing to GCP bucket...${NC}"
	@gcloud storage cp ${OUTPUT_DIR}/${TARGET_IMAGE_NAME} gs://${BUCKET_NAME}/${TARGET_IMAGE_NAME}

tarball:
	@echo "${GREEN}Creating tarball of disk.raw...${NC}"
	@tar --format=oldgnu -Sczf ${OUTPUT_DIR}/disk.raw.tar.gz ${OUTPUT_DIR}/disk.raw

images:
	@echo "${GREEN}Creating images...${NC}"
	@echo "${BLUE}gcloud compute images create ${IMAGE_NAME} --source-uri gs://${BUCKET_NAME}/${TARGET_IMAGE_NAME} --force ...${NC}"
	@gcloud compute images create ${IMAGE_NAME} --source-uri gs://${BUCKET_NAME}/${TARGET_IMAGE_NAME} --force
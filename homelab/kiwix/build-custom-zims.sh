#!/bin/bash
# Build custom ZIMs for Arrow, Parquet, and DataFusion documentation
#
# REQUIREMENTS:
#   - Docker with ~5GB free space (zimit image includes Chrome/Puppeteer)
#   - Internet access to scrape documentation sites
#   - Run on CT 107 (45GB disk, 2GB RAM) — builds take 30–90 min each
#
# Usage:
#   ./build-custom-zims.sh [arrow|parquet|datafusion|all]
#
# Output ZIMs go to ./output/ then copy to /root/kiwix/data/ and restart kiwix.

set -euo pipefail

OUTPUT_DIR="${OUTPUT_DIR:-./output}"
mkdir -p "$OUTPUT_DIR"

build_zim() {
    local name=$1
    local seed=$2
    local include_rx=$3
    local sitemap=${4:-}
    local exclude_rx=${5:-}

    echo "=== Building ZIM: $name ==="
    echo "Seed: $seed"

    local -a extra=()
    if [[ -n "$sitemap" ]]; then
        extra+=(--useSitemap "$sitemap")
    fi
    if [[ -n "$exclude_rx" ]]; then
        extra+=(--scopeExcludeRx "$exclude_rx")
    fi

    docker run --rm --shm-size=1gb \
        -v "$(realpath "$OUTPUT_DIR"):/output" \
        ghcr.io/openzim/zimit:3.1.2 \
        zimit \
        --seeds "$seed" \
        --name "$name" \
        --title "$name" \
        --output /output \
        --scopeType prefix \
        --scopeIncludeRx "$include_rx" \
        --waitUntil "load,networkidle2" \
        --workers 1 \
        --pageLimit 2000 \
        --postLoadDelay 2 \
        "${extra[@]}"

    echo "=== Done: $name ==="
    ls -lh "$OUTPUT_DIR/${name}"*.zim 2>/dev/null || ls -lh "$OUTPUT_DIR"/*.zim | tail -3
}

case "${1:-all}" in
    arrow)
        build_zim "apache-arrow-docs" \
            "https://arrow.apache.org/docs/index.html" \
            '^https://arrow\.apache\.org/docs/.*' \
            "" \
            '^https://arrow\.apache\.org/docs/(dev/|[0-9]+\.[0-9]+/).*'
        ;;
    parquet)
        build_zim "apache-parquet-docs" \
            "https://parquet.apache.org/docs/" \
            '^https://parquet\.apache\.org/docs/.*'
        ;;
    datafusion)
        build_zim "apache-datafusion-docs" \
            "https://datafusion.apache.org/user-guide/introduction.html" \
            '^https://datafusion\.apache\.org/.*' \
            "https://datafusion.apache.org/sitemap.xml"
        ;;
    all)
        if ! compgen -G "$OUTPUT_DIR/apache-parquet-docs_"*.zim > /dev/null; then
            build_zim "apache-parquet-docs" \
                "https://parquet.apache.org/docs/" \
                '^https://parquet\.apache\.org/docs/.*'
        else
            echo "Skipping parquet — already built"
        fi
        build_zim "apache-arrow-docs" \
            "https://arrow.apache.org/docs/index.html" \
            '^https://arrow\.apache\.org/docs/.*' \
            "" \
            '^https://arrow\.apache\.org/docs/(dev/|[0-9]+\.[0-9]+/).*'
        build_zim "apache-datafusion-docs" \
            "https://datafusion.apache.org/user-guide/introduction.html" \
            '^https://datafusion\.apache\.org/.*' \
            "https://datafusion.apache.org/sitemap.xml"
        ;;
    *)
        echo "Usage: $0 [arrow|parquet|datafusion|all]"
        exit 1
        ;;
esac

echo ""
echo "ZIMs built in $OUTPUT_DIR"
ls -lh "$OUTPUT_DIR"/*.zim

echo "Deploying to Kiwix..."
cp "$OUTPUT_DIR"/*.zim /root/kiwix/data/
docker restart kiwix
echo "Done. ZIMs available at http://kiwix.lan/"

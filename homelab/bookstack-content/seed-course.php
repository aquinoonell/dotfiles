<?php
/**
 * BookStack Course Seeder - Simple Version
 * Creates books and pages from markdown files.
 * Run: docker exec bookstack php /tmp/seed-course.php
 */

require_once '/app/www/vendor/autoload.php';
$app = require_once '/app/www/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

use BookStack\Entities\Models\Book;
use BookStack\Entities\Models\Chapter;
use BookStack\Entities\Models\Page;
use Illuminate\Support\Str;

// Get admin user
$adminUser = \BookStack\Users\Models\User::where('email', 'admin@admin.com')->first();
if (!$adminUser) {
    $adminUser = \BookStack\Users\Models\User::first();
}
$userId = $adminUser ? $adminUser->id : 1;

function getOrCreateBook(string $name, string $description, int $userId): Book {
    $slug = Str::slug($name);
    $book = Book::where('slug', $slug)->first();
    if (!$book) {
        $book = new Book();
        $book->name = $name;
        $book->slug = $slug;
        $book->description = $description;
        $book->created_by = $userId;
        $book->updated_by = $userId;
        $book->owned_by = $userId;
        $book->save();
        echo "Created book: $name\n";
    } else {
        echo "Book exists: $name\n";
    }
    return $book;
}

function getOrCreateChapter(Book $book, string $name, int $userId, int $priority = 0): Chapter {
    $slug = Str::slug($name);
    $chapter = Chapter::where('book_id', $book->id)->where('slug', $slug)->first();
    if (!$chapter) {
        $chapter = new Chapter();
        $chapter->book_id = $book->id;
        $chapter->name = $name;
        $chapter->slug = $slug;
        $chapter->description = '';
        $chapter->priority = $priority;
        $chapter->created_by = $userId;
        $chapter->updated_by = $userId;
        $chapter->owned_by = $userId;
        $chapter->save();
        echo "  Created chapter: $name\n";
    }
    return $chapter;
}

function upsertPage(Book $book, string $name, string $markdown, int $userId, int $priority = 0, ?Chapter $chapter = null): Page {
    $slug = Str::slug($name);
    $query = Page::where('book_id', $book->id)->where('slug', $slug);
    $page = $query->first();
    
    if (!$page) {
        $page = new Page();
        $page->book_id = $book->id;
        $page->chapter_id = $chapter ? $chapter->id : 0;
        $page->name = $name;
        $page->slug = $slug;
        $page->created_by = $userId;
        $page->owned_by = $userId;
    }
    
    $page->markdown = $markdown;
    $page->html = (new \League\CommonMark\CommonMarkConverter())->convert($markdown)->getContent();
    $page->priority = $priority;
    $page->updated_by = $userId;
    $page->draft = false;
    $page->save();
    
    echo "    Page: $name\n";
    return $page;
}

// =============================================================================
// Course Structure
// =============================================================================

echo "\n=== Seeding Rust Database Developer Course ===\n\n";

$courseDir = '/tmp/course';
$parqtoolDir = '/tmp/course/parqtool';

$courseStructure = [
    ['name' => 'Start Here', 'desc' => 'Course overview and roadmap', 'file' => '00-start-here.md'],
    ['name' => 'Phase 0-1 Setup', 'desc' => 'Environment and CS foundations', 'file' => '01-phase-0-1-setup.md'],
    ['name' => 'Rust Foundation', 'desc' => 'Complete Rust learning path', 'file' => '02-rust-foundation.md'],
    ['name' => 'Database Internals', 'desc' => 'CMU 15-445, B+Tree, WAL, MVCC', 'file' => '03-database-internals.md'],
    ['name' => 'Rust for Databases', 'desc' => 'Volcano model, Arc, ExecutionPlan', 'file' => '04-rust-for-databases.md'],
    ['name' => 'Apache Arrow', 'desc' => 'Columnar format and RecordBatch', 'file' => '05-apache-arrow.md'],
    ['name' => 'Parquet', 'desc' => 'File format deep dive', 'file' => '06-parquet.md'],
    ['name' => 'DataFusion', 'desc' => 'Query engine architecture', 'file' => '07-datafusion.md'],
    ['name' => 'Distributed Systems', 'desc' => 'Raft, OSS contributions', 'file' => '08-distributed-systems.md'],
    ['name' => 'Reference', 'desc' => 'Resource index and translation guide', 'file' => '09-resources.md'],
];

// Create a single course book with chapters for each section
$courseBook = getOrCreateBook(
    'Rust Database Developer Course',
    'Complete curriculum: databases, distributed systems, and open source in Rust',
    $userId
);

$priority = 0;
foreach ($courseStructure as $section) {
    $priority++;
    $filePath = $courseDir . '/' . $section['file'];
    
    if (file_exists($filePath)) {
        $content = file_get_contents($filePath);
        
        // Extract title from first heading
        preg_match('/^#\s+(.+)$/m', $content, $matches);
        $pageTitle = $matches[1] ?? $section['name'];
        
        // Create chapter and page
        $chapter = getOrCreateChapter($courseBook, $section['name'], $userId, $priority);
        upsertPage($courseBook, $pageTitle, $content, $userId, 1, $chapter);
    } else {
        echo "WARNING: File not found: $filePath\n";
    }
}

// Create parq-tool book
echo "\n--- parq-tool Guide ---\n";

$parqtoolBook = getOrCreateBook(
    'parq-tool Build Guide',
    'CLI for Parquet, DataFusion SQL, and Postgres - complete tutorial',
    $userId
);

$parqtoolChapters = [
    ['file' => '00-how-to-read-docs.md', 'name' => 'Getting Started'],
    ['file' => '01-layer1-parquet.md', 'name' => 'Layer 1 Read Parquet'],
    ['file' => '02-layer2-datafusion.md', 'name' => 'Layer 2 DataFusion SQL'],
    ['file' => '03-layer3-write.md', 'name' => 'Layer 3 Write Parquet'],
    ['file' => '04-layer4-postgres.md', 'name' => 'Layer 4 Write to Postgres'],
    ['file' => '05-layer5-cli.md', 'name' => 'Layer 5 CLI Polish'],
];

$priority = 0;
foreach ($parqtoolChapters as $section) {
    $priority++;
    $filePath = $parqtoolDir . '/' . $section['file'];
    
    if (file_exists($filePath)) {
        $content = file_get_contents($filePath);
        
        preg_match('/^#\s+(.+)$/m', $content, $matches);
        $pageTitle = $matches[1] ?? $section['name'];
        
        $chapter = getOrCreateChapter($parqtoolBook, $section['name'], $userId, $priority);
        upsertPage($parqtoolBook, $pageTitle, $content, $userId, 1, $chapter);
    } else {
        echo "WARNING: File not found: $filePath\n";
    }
}

// Seed runbooks
echo "\n--- Runbooks ---\n";

$runbooksBook = getOrCreateBook(
    'Runbooks',
    'Homelab operational guides — Kiwix, services',
    $userId
);

$runbooksDir = '/tmp/runbooks';
$runbookFiles = glob($runbooksDir . '/*.md') ?: [];
sort($runbookFiles);
$priority = 0;
foreach ($runbookFiles as $filePath) {
    $priority++;
    $content = file_get_contents($filePath);
    preg_match('/^#\s+(.+)$/m', $content, $matches);
    $pageTitle = $matches[1] ?? basename($filePath, '.md');
    upsertPage($runbooksBook, $pageTitle, $content, $userId, $priority);
}

Artisan::call('bookstack:regenerate-permissions');
echo Artisan::output();

echo "\n=== Course seeding complete ===\n";
echo "View at: /books/rust-database-developer-course\n";
echo "parq-tool at: /books/parq-tool-build-guide\n";
echo "runbooks at: /books/runbooks\n\n";

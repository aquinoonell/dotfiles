<?php
/**
 * Remove empty/stub/duplicate BookStack books superseded by the main course.
 * Run: docker exec bookstack php /tmp/cleanup-bookstack.php
 */

require_once '/app/www/vendor/autoload.php';
$app = require_once '/app/www/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

use BookStack\Entities\Models\Book;
use BookStack\Entities\Models\Chapter;
use BookStack\Entities\Models\Page;

$keepSlugs = [
    'rust-database-developer-course',
    'parq-tool-build-guide',
    'homelab-setup-commands',
    'runbooks',
];

$books = Book::all();
foreach ($books as $book) {
    if (in_array($book->slug, $keepSlugs, true)) {
        echo "KEEP: {$book->name} ({$book->slug})\n";
        continue;
    }

    $pageCount = Page::where('book_id', $book->id)->count();
    $mdChars = Page::where('book_id', $book->id)->get()->sum(fn ($p) => strlen($p->markdown ?? ''));
    $htmlChars = Page::where('book_id', $book->id)->get()->sum(fn ($p) => strlen($p->html ?? ''));

    echo "DELETE: {$book->name} ({$book->slug}) pages={$pageCount} md={$mdChars} html={$htmlChars}\n";

    Chapter::where('book_id', $book->id)->delete();
    Page::where('book_id', $book->id)->delete();
    $book->delete();
}

echo "\nRegenerating permissions...\n";
Artisan::call('bookstack:regenerate-permissions');
echo Artisan::output();
echo "\nCleanup complete.\n";

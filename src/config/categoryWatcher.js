const chokidar = require('chokidar');
const fs = require('fs');
const categoriesPath = __dirname + '/categories.js';
const categoryUpdatedQueue = require('./queue-config');

const initCategoryWatcher = () => {
  const watcher = chokidar.watch(categoriesPath, { ignoreInitial: true });

  watcher.on('change', async () => {
    console.log('📁 categories.js changed → publishing event');

    // Clear cache to force fresh load
    delete require.cache[require.resolve(categoriesPath)];

    // Load updated JS module
    const newConfig = require(categoriesPath);

    // Publish event to queue
    await categoryUpdatedQueue.add('CATEGORIES_UPDATED', {
      timestamp: Date.now(),
      newCategories: newConfig,
    });
  });

  console.log('👀 Watching categories.js for changes...');
};

module.exports = initCategoryWatcher;

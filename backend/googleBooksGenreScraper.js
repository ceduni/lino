import fs from 'fs';

class GoogleBooksGenreScraper {
  constructor(apiKey = null) {
    this.apiKey = apiKey;
    this.baseUrl = 'https://www.googleapis.com/books/v1/volumes';
    this.genres = new Set();
    this.genreFile = 'book_genres.json';
    
    // Comprehensive subjects to seed the scraping
    this.seedSubjects = [
      // Main fiction categories
      'fiction', 'literary fiction', 'contemporary fiction', 'historical fiction',
      'science fiction', 'fantasy', 'dystopian', 'urban fantasy', 'epic fantasy',
      'mystery', 'thriller', 'suspense', 'crime', 'detective', 'cozy mystery',
      'romance', 'contemporary romance', 'historical romance', 'paranormal romance',
      'horror', 'psychological horror', 'supernatural', 'gothic',
      'adventure', 'action', 'war', 'western', 'spy',
      
      // Age categories
      'young adult', 'teen', 'middle grade', 'children', 'picture books',
      'new adult', 'coming of age',
      
      // Non-fiction categories
      'biography', 'autobiography', 'memoir', 'history', 'true crime',
      'self help', 'personal development', 'psychology', 'philosophy',
      'business', 'entrepreneurship', 'finance', 'economics', 'management',
      'health', 'fitness', 'diet', 'nutrition', 'medicine',
      'science', 'nature', 'environment', 'physics', 'biology', 'chemistry',
      'technology', 'computers', 'programming', 'artificial intelligence',
      'politics', 'social science', 'sociology', 'anthropology',
      'religion', 'spirituality', 'christianity', 'islam', 'buddhism',
      'education', 'parenting', 'relationships', 'family',
      'travel', 'cooking', 'food', 'crafts', 'hobbies', 'gardening',
      'art', 'photography', 'design', 'architecture',
      'music', 'performing arts', 'theater', 'dance',
      'sports', 'recreation', 'fitness', 'outdoor',
      'poetry', 'drama', 'essays', 'humor', 'satire',
      
      // Specific genres that often get missed
      'steampunk', 'cyberpunk', 'space opera', 'time travel',
      'alternate history', 'post apocalyptic', 'magical realism',
      'noir', 'hardboiled', 'police procedural', 'legal thriller',
      'medical thriller', 'political thriller', 'espionage',
      'erotica', 'lgbtq', 'multicultural', 'womens fiction'
    ];
  }

  /**
   * Build API URL with optional API key
   */
  buildApiUrl(query, maxResults = 40) {
    const params = new URLSearchParams({
      q: query,
      maxResults: maxResults.toString()
    });
    
    if (this.apiKey) {
      params.append('key', this.apiKey);
    }
    
    return `${this.baseUrl}?${params.toString()}`;
  }

  /**
   * Fetch books from Google Books API
   */
  async fetchBooks(query, maxResults = 40) {
    try {
      const url = this.buildApiUrl(query, maxResults);
      const response = await fetch(url);
      
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }
      
      const data = await response.json();
      return data.items || [];
    } catch (error) {
      console.error(`Error fetching books for query "${query}":`, error);
      return [];
    }
  }

  /**
   * Extract and normalize genres from a book item
   */
  extractGenresFromBook(bookItem) {
    const genres = new Set();
    const volumeInfo = bookItem.volumeInfo;
    
    // Extract from categories
    if (volumeInfo.categories) {
      volumeInfo.categories.forEach(category => {
        this.normalizeAndAddGenre(category, genres);
      });
    }
    
    // Extract from subjects (if available)
    if (volumeInfo.subjects) {
      volumeInfo.subjects.forEach(subject => {
        this.normalizeAndAddGenre(subject, genres);
      });
    }
    
    return Array.from(genres);
  }

  /**
   * Normalize genre strings and add to set
   */
  normalizeAndAddGenre(rawGenre, genreSet) {
    if (!rawGenre || typeof rawGenre !== 'string') return;
    
    // Clean up the genre string
    let normalized = rawGenre
      .split(/[\/\-\|]/)  // Split on /, -, or |
      .map(part => part.trim())
      .filter(part => part.length > 0)
      .map(part => {
        // Remove common prefixes/suffixes but be more selective
        return part
          .replace(/^(Fiction|Non-fiction|Nonfiction)\s*[-\/]?\s*/i, '')
          .replace(/\s*[-\/]\s*(Fiction|Non-fiction|Nonfiction)$/i, '')
          .replace(/\s+/g, ' ')
          .trim();
      })
      .filter(part => part.length > 0); // Remove empty parts
    
    // Also add the original genre without splitting if it's not too long
    if (rawGenre.length < 50 && !rawGenre.includes('/')) {
      normalized.push(rawGenre.trim());
    }
    
    normalized.forEach(genre => {
      if (this.isValidGenre(genre)) {
        genreSet.add(this.capitalizeGenre(genre));
      }
    });
  }

  /**
   * Check if a genre is valid (not too generic or meaningless)
   */
  isValidGenre(genre) {
    const invalidGenres = [
      'general', 'miscellaneous', 'other', 'unknown', 'various',
      'literature', 'books', 'reading', 'library', 'collection',
      'text', 'study', 'reference', 'guide', 'handbook'
    ];
    
    return genre.length > 1 && // Allow shorter genres like "SF"
           !invalidGenres.includes(genre.toLowerCase()) &&
           !/^\d+$/.test(genre) && // Not just numbers
           !/^[A-Z]{1,2}\d/.test(genre); // Not codes like "PZ7" or "B123"
  }

  /**
   * Capitalize genre properly
   */
  capitalizeGenre(genre) {
    return genre
      .split(' ')
      .map(word => word.charAt(0).toUpperCase() + word.slice(1).toLowerCase())
      .join(' ')
      .replace(/\bAnd\b/g, 'and')
      .replace(/\bOf\b/g, 'of')
      .replace(/\bThe\b/g, 'the');
  }

  /**
   * Scrape genres from seed subjects
   */
  async scrapeGenresFromSeeds() {
    console.log('Starting genre scraping from seed subjects...');
    
    for (const subject of this.seedSubjects) {
      console.log(`Scraping subject: ${subject}`);
      
      // Try multiple query formats to get more comprehensive results
      const queries = [
        `subject:${subject}`,
        `intitle:${subject}`,
        `${subject}` // Simple search
      ];
      
      for (const query of queries) {
        const books = await this.fetchBooks(query, 40);
        
        books.forEach(book => {
          const bookGenres = this.extractGenresFromBook(book);
          bookGenres.forEach(genre => this.genres.add(genre));
        });
        
        // Small delay between queries
        await this.delay(50);
      }
      
      // Be nice to the API - add a small delay between subjects
      await this.delay(100);
    }
    
    console.log(`Scraped ${this.genres.size} unique genres from seed subjects`);
  }

  /**
   * Extract genres from a single book by ISBN
   */
  async extractGenresFromISBN(isbn) {
    const books = await this.fetchBooks(`isbn:${isbn}`);
    const allGenres = [];
    
    books.forEach(book => {
      const bookGenres = this.extractGenresFromBook(book);
      allGenres.push(...bookGenres);
      bookGenres.forEach(genre => this.genres.add(genre));
    });
    
    return allGenres;
  }

  /**
   * Save genres to file
   */
  async saveGenresToFile() {
    const genreArray = Array.from(this.genres).sort();
    const genreData = {
      lastUpdated: new Date().toISOString(),
      totalGenres: genreArray.length,
      genres: genreArray
    };
    
    // In a browser environment, you might want to download the file
    // In Node.js, you would use fs.writeFileSync
    if (typeof window !== 'undefined') {
      // Browser environment - create download
      const blob = new Blob([JSON.stringify(genreData, null, 2)], {
        type: 'application/json'
      });
      const url = URL.createObjectURL(blob);
      const a = document.createElement('a');
      a.href = url;
      a.download = this.genreFile;
      a.click();
      URL.revokeObjectURL(url);
    } else {
      // Node.js environment
      fs.writeFileSync(this.genreFile, JSON.stringify(genreData, null, 2));
    }
    
    console.log(`Saved ${genreArray.length} genres to ${this.genreFile}`);
  }

  /**
   * Load existing genres from file
   */
  async loadGenresFromFile() {
    try {
      let data;
      if (typeof window !== 'undefined') {
        // Browser environment
        const response = await fetch(this.genreFile);
        data = await response.json();
      } else {
        // Node.js environment
        const fileContent = fs.readFileSync(this.genreFile, 'utf8');
        data = JSON.parse(fileContent);
      }
      
      if (data.genres) {
        data.genres.forEach(genre => this.genres.add(genre));
        console.log(`Loaded ${data.genres.length} genres from file`);
      }
    } catch (error) {
      console.log('No existing genre file found, starting fresh');
    }
  }

  /**
   * Get all genres as array
   */
  getAllGenres() {
    return Array.from(this.genres).sort();
  }

  /**
   * Search genres with fuzzy matching
   */
  searchGenres(query, maxResults = 10) {
    const lowerQuery = query.toLowerCase();
    const allGenres = this.getAllGenres();
    
    return allGenres
      .filter(genre => genre.toLowerCase().includes(lowerQuery))
      .slice(0, maxResults);
  }

  /**
   * Utility delay function
   */
  delay(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
  }

  /**
   * Main function to run the complete scraping process
   */
  async runFullScrape() {
    console.log('Starting full genre scraping process...');
    
    // Load existing genres
    await this.loadGenresFromFile();
    console.log(`Starting with ${this.genres.size} existing genres`);
    
    // Scrape from seed subjects
    await this.scrapeGenresFromSeeds();
    
    // Add some essential genres that might be missed
    const essentialGenres = [
      'Fiction', 'Science Fiction', 'Fantasy', 'Mystery', 'Romance',
      'Thriller', 'Horror', 'Biography', 'History', 'Non-fiction',
      'Young Adult', 'Children', 'Poetry', 'Drama', 'Adventure',
      'Crime', 'Suspense', 'Contemporary Fiction', 'Historical Fiction',
      'Literary Fiction', 'Self Help', 'Business', 'Health', 'Travel',
      'Cooking', 'Art', 'Music', 'Sports', 'Technology', 'Science'
    ];
    
    essentialGenres.forEach(genre => this.genres.add(genre));
    
    // Save to file
    await this.saveGenresToFile();
    
    console.log('Genre scraping complete!');
    console.log(`Total genres collected: ${this.genres.size}`);
    console.log('Sample genres:', Array.from(this.genres).slice(0, 20));
    
    return this.getAllGenres();
  }
}

// Usage examples:

// Initialize scraper (with optional API key for higher rate limits)
const scraper = new GoogleBooksGenreScraper(process.env.GOOGLE_API_KEY);

// Run full scrape
scraper.runFullScrape();

// Or extract genres from a specific book ISBN
// scraper.extractGenresFromISBN('9780123456789');

// Search existing genres
// scraper.searchGenres('fantasy', 5);

export default GoogleBooksGenreScraper;
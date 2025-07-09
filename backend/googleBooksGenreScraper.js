import fs from 'fs';

class GoogleBooksGenreScraper {
  constructor(apiKey = null) {
    this.apiKey = apiKey;
    this.baseUrl = 'https://www.googleapis.com/books/v1/volumes';
    this.genres = new Set();
    this.genreFile = 'book_genres.json';
    
    // Popular subjects to seed the scraping
    this.seedSubjects = [
      'fiction', 'mystery', 'romance', 'science fiction', 'fantasy',
      'thriller', 'horror', 'biography', 'history', 'self help',
      'business', 'cooking', 'travel', 'poetry', 'drama',
      'adventure', 'crime', 'historical fiction', 'young adult',
      'children', 'philosophy', 'religion', 'health', 'sports',
      'art', 'music', 'technology', 'science', 'nature'
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
      .split('/')  // Split "Fiction / Mystery & Detective"
      .map(part => part.trim())
      .filter(part => part.length > 0)
      .map(part => {
        // Remove common prefixes/suffixes
        return part
          .replace(/^(Fiction|Non-fiction|Nonfiction)\s*[-\/]?\s*/i, '')
          .replace(/\s*[-\/]\s*(Fiction|Non-fiction|Nonfiction)$/i, '')
          .replace(/\s+/g, ' ')
          .trim();
      })
      .filter(part => part.length > 2); // Remove very short parts
    
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
      'literature', 'books', 'reading', 'library', 'collection'
    ];
    
    return genre.length > 2 && 
           !invalidGenres.includes(genre.toLowerCase()) &&
           !/^\d+$/.test(genre); // Not just numbers
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
      
      const books = await this.fetchBooks(`subject:${subject}`);
      
      books.forEach(book => {
        const bookGenres = this.extractGenresFromBook(book);
        bookGenres.forEach(genre => this.genres.add(genre));
      });
      
      // Be nice to the API - add a small delay
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
      // This would need to be adapted based on your environment
      // For browser: fetch the file or use FileReader
      // For Node.js: use fs.readFileSync
      const response = await fetch(this.genreFile);
      const data = await response.json();
      
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
    
    // Scrape from seed subjects
    await this.scrapeGenresFromSeeds();
    
    // Save to file
    await this.saveGenresToFile();
    
    console.log('Genre scraping complete!');
    console.log(`Total genres collected: ${this.genres.size}`);
    
    return this.getAllGenres();
  }
}

// Initialize scraper 
const scraper = new GoogleBooksGenreScraper(process.env.GOOGLE_API_KEY); 

// Run full scrape
scraper.runFullScrape();

// Extract genres from a specific book ISBN
// scraper.extractGenresFromISBN('9780123456789');

// Search existing genres
// scraper.searchGenres('fantasy', 5);

export default GoogleBooksGenreScraper;
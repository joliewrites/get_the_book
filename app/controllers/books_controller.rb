class BooksController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index, :show]
  before_action :find_book, only: [:show, :edit, :update, :destroy]

  def index
    @books = policy_scope(Book)
    if params[:query].present?
      sql_query = "title ILIKE :query OR author ILIKE :query OR year = :query_year"
      @books = Book.where(sql_query, query: "%#{params[:query]}%", query_year: params[:query].to_i)
    else
      @books = Book.all
    end
  end

  def my_books
    @books = current_user.books
  end

  def show
  end

  def new
    @book = Book.new
    authorize @book
  end

  def create
    @book = Book.new(book_params)
    @book.owner_id = current_user.id
    authorize @book

    if @book.save
      redirect_to book_path(@book)
    else
      render :new
    end
  end

  def edit
  end

  def update
    @book.update(book_params)
    redirect_to book_path(@book)
  end

  def destroy
    @book.destroy

    redirect_to books_path
  end

  private

  def find_book
    @book = Book.find(params[:id])
    authorize @book
  end

  def book_params
    params.require(:book).permit(:name, :year, :title, :description, :condition, :author, :owner_id, :price, :photo)
  end
end

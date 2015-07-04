package App::Sqitch::GUI::Wx::LogView;

# ABSTRACT: Logger control with syntax highlighting

use Moo;
use Wx::Scintilla 0.34 ();
use Wx qw(
    wxDEFAULT
    wxNORMAL
    wxSTC_LEX_MSSQL
    wxSTC_MARGIN_SYMBOL
    wxSTC_STYLE_DEFAULT
    wxSTC_WRAP_NONE
);
use Wx::Event;

with 'App::Sqitch::GUI::Roles::Element';

extends 'Wx::Scintilla::TextCtrl';

sub FOREIGNBUILDARGS {
    my $self = shift;
    my %args = @_;
    return (
        $args{parent},
        -1,
        [-1, -1],
        [-1, -1],
    );
}

sub BUILD {
    my $self = shift;

    $self->StyleSetBackground( wxSTC_STYLE_DEFAULT, Wx::Colour->new('WHEAT') );
    $self->SetMarginType( 1, wxSTC_MARGIN_SYMBOL );
    $self->SetMarginWidth( 1, 0 );
    $self->SetWrapMode(wxSTC_WRAP_NONE);    # wxSTC_WRAP_WORD
    $self->StyleSetFont( wxSTC_STYLE_DEFAULT,
        Wx::Font->new( 10, wxDEFAULT, wxNORMAL, wxNORMAL, 0, 'Courier New' )
    );
    $self->SetLexer(wxSTC_LEX_MSSQL);
    $self->SetWrapMode(wxSTC_WRAP_NONE);    # wxSTC_WRAP_WORD

    # List0
    $self->SetKeyWords( 0, q{ii} );

    # List1
    $self->SetKeyWords( 1, q{ee} );

    # List2
    $self->SetKeyWords( 2, q{ww} );

    $self->SetTabWidth(4);
    $self->SetIndent(4);
    $self->SetHighlightGuide(4);
    $self->StyleClearAll();

    # MSSQL - works with wxSTC_LEX_MSSQL
    $self->StyleSetSpec( 3,  "fore:#0000ff" );    #*Number
    $self->StyleSetSpec( 4,  "fore:#dca3a3" );    #*Singlequoted
    $self->StyleSetSpec( 8,  "fore:#705050" );    #*Doublequoted
    $self->StyleSetSpec( 9,  "fore:#00ff00" );    #*List0
    $self->StyleSetSpec( 10, "fore:#ff0000" );    #*List1
    $self->StyleSetSpec( 11, "fore:#0000ff" );    #*List2

    return $self;
}

sub _set_events {
    return 1;
}

1;

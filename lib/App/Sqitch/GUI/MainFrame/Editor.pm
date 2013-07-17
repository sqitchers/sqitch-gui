package App::Sqitch::GUI::MainFrame::Editor;

use Moose;
use Wx qw(:everything);
use Wx::STC;
use Wx::Event qw();

with 'App::Sqitch::GUI::Roles::Element';

use MooseX::NonMoose::InsideOut;
extends 'Wx::StyledTextCtrl';

sub FOREIGNBUILDARGS {
    my $self = shift;

    my %args = @_;

    return (
        $args{parent},
        -1,
        [-1, -1],
        [-1, -1],
        wxBORDER_SUNKEN,
    );
}

sub BUILD {
    my $self = shift;

    #
    # From QDepo (http://sourceforge.net/projects/tpda-qrt/)  ;)
    #
    $self->SetMarginType( 1, wxSTC_MARGIN_SYMBOL );
    $self->SetMarginType( 1, wxSTC_MARGIN_SYMBOL );
    $self->SetMarginWidth( 1, 10 );
    $self->StyleSetFont( wxSTC_STYLE_DEFAULT,
        Wx::Font->new( 10, wxDEFAULT, wxNORMAL, wxNORMAL, 0, 'Courier New' ) );
    # $self->SetLexer( wxSTC_LEX_SQL );
    $self->SetLexer( wxSTC_LEX_MSSQL );
    # List0
    $self->SetKeyWords(0,
    q{all and any ascending between by cast collate containing day
descending distinct escape exists from full group having in
index inner into is join left like merge month natural not
null on order outer plan right select singular some sort starting
transaction union upper user where with year} );
    # List1
    $self->SetKeyWords(1,
    q{blob char decimal integer number varchar} );
    # List2 Only for MSSQL?
    $self->SetKeyWords(2, q{avg count gen_id max min sum} );
    $self->SetTabWidth(4);
    $self->SetIndent(4);
    $self->SetHighlightGuide(4);

    $self->StyleClearAll();

    # Global default styles for all languages
    $self->StyleSetSpec( wxSTC_STYLE_BRACELIGHT,
                                "fore:#FFFFFF,back:#0000FF,bold" );
    $self->StyleSetSpec( wxSTC_STYLE_BRACEBAD,
                                "fore:#000000,back:#FF0000,bold" );

    # MSSQL - works with wxSTC_LEX_MSSQL
    $self->StyleSetSpec(0, "fore:#000000");            #*Default
    $self->StyleSetSpec(1, "fore:#ff7373,italic");     #*Comment
    $self->StyleSetSpec(2, "fore:#007f7f,italic");     #*Commentline
    $self->StyleSetSpec(3, "fore:#0000ff");            #*Number
    $self->StyleSetSpec(4, "fore:#dca3a3");            #*Singlequoted
    $self->StyleSetSpec(5, "fore:#3f3f3f");            #*Operation
    $self->StyleSetSpec(6, "fore:#000000");            #*Identifier
    $self->StyleSetSpec(7, "fore:#8cd1d3");            #*@-Variable
    $self->StyleSetSpec(8, "fore:#705050");            #*Doublequoted
    $self->StyleSetSpec(9, "fore:#dfaf8f");            #*List0
    $self->StyleSetSpec(10,"fore:#94c0f3");            #*List1
    $self->StyleSetSpec(11,"fore:#705030");            #*List2

    return $self;
};

sub _set_events {
    return 1;
}

no Moose;
__PACKAGE__->meta->make_immutable;


1;

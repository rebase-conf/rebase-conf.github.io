$(document).ready(function () {
    $('.box__person-links').click(function(e) {
        e.preventDefault();
        $('.overlay--person').toggleClass('overlay--active');
    });

    $('a[href="#abstract"]').click(function(e) {
        e.preventDefault();
        $('.overlay--talk').toggleClass('overlay--active');
    });

    $('.overlay').click(function (e) {
        if (e.target === e.currentTarget) {
            $(this).toggleClass('overlay--active');
        }
    });
});

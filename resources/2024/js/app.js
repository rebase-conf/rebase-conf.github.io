$(document).ready(function () {
  $(".button--inactive").click(function (e) {
    e.preventDefault();
  });

  $(".overlay__close").click(function (e) {
    e.preventDefault();
    closeOverlay();
  });

  $("[data-overlay=person]").click(function (e) {
    e.preventDefault();
    var $this = $(this);
    $personEl = $this.closest(".box__person");
    fillPersonOverlay($personEl);
    showOverlay(".overlay--person", $this.attr("href"));
  });

  $("[data-overlay=talk]").click(function (e) {
    e.preventDefault();
    var $this = $(this);
    $talkEl = $this.closest(".box");
    fillTalkOverlay($talkEl);
    showOverlay(".overlay--talk", $this.attr("href"));
  });

  $(".overlay").click(function (e) {
    var $target = $(e.target);
    if (
      !$target.hasClass("overlay__close") &&
      $target.closest(".box").length === 0
    ) {
      closeOverlay();
    }
  });

  if (window.location.hash) {
    var $overlayLink = $('[data-overlay][href="' + window.location.hash + '"]');
    if ($overlayLink.length) {
      var $parent = $overlayLink.closest(".box");
      $("html,body").scrollTop($parent.offset().top);
      $overlayLink[0].click();
    }
  }

  $("[rel=smooth-scroll]").click(function (e) {
    e.preventDefault();
    var $target = $($(this).attr("href"));
    if ($target.length) {
      $("html, body").animate({ scrollTop: $target.offset().top });
    }
  });
});

// Opening/closing the overlay is a bit complicated only to prevent overscroll in it
closeOverlay = function () {
  $(".overlay").removeClass("overlay--active");
  var $body = $("body");
  var scrollPosition = -1 * parseInt($body.css("marginTop"));
  $body.removeClass("body--overlay-active").css({ marginTop: 0 });
  $("html,body").scrollTop(scrollPosition);
  window.history.replaceState({}, null, window.location.pathname);
};

showOverlay = function (overlay, href) {
  var $overlay = $(overlay);
  scrollPosition = $("html").scrollTop();
  $overlay.addClass("overlay--active");
  $(".overlay__content-scroll").scrollTop(0);
  $("body")
    .addClass("body--overlay-active")
    .css({ marginTop: -scrollPosition });
  window.history.replaceState({}, null, href);
};

fillPersonOverlay = function ($personEl) {
  var $box = $(".overlay--person .box");
  var $clone = $personEl.clone();

  // Remove elements we do not want to see in the overlay
  $clone.find(".box__person-name").unwrap();
  $clone.find("[data-overlay]").remove();

  // Replace the overlay content
  $box.find(".box__person").replaceWith($clone);

  // Append speaker's bio
  var speaker = speakers[$personEl.attr("data-id")];
  $box.find(".box__text-content").empty().append(speaker);
};

fillTalkOverlay = function ($talkEl) {
  var $clone = $talkEl.clone();
  var $box = $(".overlay--talk .box");

  // Remove elements we do not want to see in the overlay
  $clone.find(".box__text-content").remove();
  $clone.find(".box__text-heading").unwrap();
  $clone.find(".box__text-links [data-overlay]").remove();
  $clone.find(".box__video").remove();

  // Empty the overlay box and append cloned node to it
  $box.empty();
  $box.append($clone.children());

  // Append text data (abstract and speakrs' bios)
  $text = $('<div class="box__text-content"></div>');
  talk = talks[$talkEl.attr("data-id")];
  $text.append("<h3>Abstract</h3>");
  $text.append(talk.abstract);
  talk.speakers.forEach(function (speaker) {
    if (speaker.bio != "\n") {
      $text.append("<h3>About " + speaker.name + "</h3>");
      $text.append(speaker.bio);
    }
  });
  if (talk.video_id) {
    $text.append("<h3>Video</h3>");
    $text.append(
      '<iframe width="560" height="315" src="https://www.youtube.com/embed/' +
        talk.video_id +
        '" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>',
    );
  }
  $box.append($text);
};

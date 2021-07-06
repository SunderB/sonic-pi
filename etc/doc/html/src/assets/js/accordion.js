// From https://css-tricks.com/how-to-animate-the-details-element-using-waapi/ by Louis Hoebregts
//
// class Accordion {
//   constructor(el) {
//     this.el = el; // Store the <details> element
//     this.summary = el.querySelector('summary'); // Store the <summary> element
//     this.content = el.querySelector('.content'); // Store the <div class="content"> element
//
//     // Store the animation object (so we can cancel it if needed)
//     this.animation = null;
//
//     // Store current state
//     this.isClosing = false;
//     this.isExpanding = false;
//
//     // Detect user clicks on the summary element
//     this.summary.addEventListener('click', (e) => this.onClick(e));
//   }
//
//   onClick(e) {
//     // Stop default behaviour from the browser
//     e.preventDefault();
//
//     // Add an overflow on the <details> to avoid content overflowing
//     this.el.style.overflow = 'hidden';
//
//     // Check if the element is being closed or is already closed
//     if (this.isClosing || !this.el.open) {
//       this.animate(true);
//     // Check if the element is being openned or is already open
//     } else if (this.isExpanding || this.el.open) {
//       this.animate(false);
//     }
//   }
//
//   animate(expand) {
//     const startHeight = `${this.el.offsetHeight}px`;
//     var endHeight;
//
//     if (expand == false) {
//       // Set the element as "being closed"
//       this.isClosing = true;
//       endHeight = `${this.summary.offsetHeight}px`;
//     } else {
//       // Set the element as "being expanding"
//       this.isExpanding = true;
//       // Calculate the open height of the element (summary height + content height)
//       endHeight = `${this.summary.offsetHeight + this.content.offsetHeight}px`;
//     }
//
//     // If there is already an animation running, cancel it.
//     if (this.animation) {
//       this.animation.cancel();
//     }
//
//     // Start a WAAPI animation
//     this.animation = this.el.animate({
//       // Set the keyframes from the startHeight to endHeight
//       height: [startHeight, endHeight]
//     }, {
//       duration: 400,
//       easing: 'ease-in'
//     });
//
//     // When the animation is complete, call onAnimationFinish()
//     this.animation.onfinish = () => this.onAnimationFinish(expand);
//     // If the animation is cancelled, isClosing variable is set to false
//     this.animation.oncancel = () => {
//       if (expand) {
//         this.isExpanding = false;
//       } else {
//         this.isClosing = false;
//       }
//     };
//   }
//
//   open() {
//     // Apply a fixed height on the element
//     this.el.style.height = `${this.el.offsetHeight}px`;
//     // Force the [open] attribute on the details element
//     this.el.open = true;
//     // Wait for the next frame to call the expand function
//     window.requestAnimationFrame(() => this.expand());
//   }
//
//   onAnimationFinish(open) {
//     // Set the open attribute based on the parameter
//     this.el.open = open;
//     // Clear the stored animation
//     this.animation = null;
//     // Reset isClosing & isExpanding
//     this.isClosing = false;
//     this.isExpanding = false;
//     // Remove the overflow hidden and the fixed height
//     this.el.style.height = this.el.style.overflow = '';
//   }
// }
//
// window.onload = function () {
//   document.querySelectorAll('details').forEach((el) => {
//     console.log(el);
//     new Accordion(el);
//   });
// }


class Accordion {
  constructor(el) {
    // Store the <details> element
    this.el = el;
    // Store the <summary> element
    this.summary = el.querySelector('summary');
    // Store the <div class="content"> element
    this.content = el.querySelector('.content');

    // Store the animation object (so we can cancel it if needed)
    this.animation = null;
    // Store if the element is closing
    this.isClosing = false;
    // Store if the element is expanding
    this.isExpanding = false;
    // Detect user clicks on the summary element
    this.summary.addEventListener('click', (e) => this.onClick(e));
  }

  onClick(e) {
    // Stop default behaviour from the browser
    e.preventDefault();
    // Add an overflow on the <details> to avoid content overflowing
    this.el.style.overflow = 'hidden';
    // Check if the element is being closed or is already closed
    if (this.isClosing || !this.el.open) {
      this.open();
    // Check if the element is being openned or is already open
    } else if (this.isExpanding || this.el.open) {
      this.shrink();
    }
  }

  shrink() {
    // Set the element as "being closed"
    this.isClosing = true;

    // Store the current height of the element
    const startHeight = this.el.offsetHeight;
    // Calculate the height of the summary
    const endHeight = this.summary.offsetHeight;

    // If there is already an animation running
    if (this.animation) {
      // Cancel the current animation
      this.animation.cancel();
    }

    const duration = Math.max(1, 2 * Math.abs(startHeight - endHeight));

    // Start a WAAPI animation
    this.animation = this.el.animate({
      // Set the keyframes from the startHeight to endHeight
      height: [`${startHeight}px`, `${endHeight}px`]
    }, {
      duration: duration,
      easing: 'ease-in-out'
    });

    // When the animation is complete, call onAnimationFinish()
    this.animation.onfinish = () => this.onAnimationFinish(false);
    // If the animation is cancelled, isClosing variable is set to false
    this.animation.oncancel = () => this.isClosing = false;
  }

  open() {
    // Apply a fixed height on the element
    this.el.style.height = `${this.el.offsetHeight}px`;
    // Force the [open] attribute on the details element
    this.el.open = true;
    // Wait for the next frame to call the expand function
    window.requestAnimationFrame(() => this.expand());
  }

  expand() {
    // Set the element as "being expanding"
    this.isExpanding = true;
    // Get the current fixed height of the element
    const startHeight = this.el.offsetHeight;
    // Calculate the open height of the element (summary height + content height)
    const endHeight = this.summary.offsetHeight + this.content.offsetHeight;

    // If there is already an animation running
    if (this.animation) {
      // Cancel the current animation
      this.animation.cancel();
    }

    const duration = Math.max(1, 2 * Math.abs(startHeight - endHeight));

    // Start a WAAPI animation
    this.animation = this.el.animate({
      // Set the keyframes from the startHeight to endHeight
      height: [`${startHeight}px`, `${endHeight}px`]
    }, {
      duration: duration,
      easing: 'ease-in-out'
    });
    // When the animation is complete, call onAnimationFinish()
    this.animation.onfinish = () => this.onAnimationFinish(true);
    // If the animation is cancelled, isExpanding variable is set to false
    this.animation.oncancel = () => this.isExpanding = false;
  }

  onAnimationFinish(open) {
    // Set the open attribute based on the parameter
    this.el.open = open;
    // Clear the stored animation
    this.animation = null;
    // Reset isClosing & isExpanding
    this.isClosing = false;
    this.isExpanding = false;
    // Remove the overflow hidden and the fixed height
    this.el.style.height = this.el.style.overflow = '';
  }
}

function initialise() {
  const prefersReducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)');
  if (!prefersReducedMotion) {
    document.querySelectorAll('details').forEach((el) => {
      new Accordion(el);
    });
  }
}

window.addEventListener("load", initialise, false);

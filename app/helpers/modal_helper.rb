module ModalHelper
  def modal_link_helper(title, path, **options)
    options[:data] ||= {}
    options[:data][:turbo_frame] = "modal"

    link_to title, path, **options
  end

  def modal_container_helper(title: "", &block)
    turbo_frame_tag "modal" do
      tag.div data: { controller: "turbo-modal", action: "keydown.esc->turbo-modal#hideModal" }, tabindex: 0, class: "fixed inset-0" do
        tag.div(class: "fixed inset-0 w-full h-full bg-gray-700/60 z-51", data: { action: "click->turbo-modal#hideModal" }) +
        tag.div(class: "card absolute top-1/2 left-1/2 transform -translate-x-1/2 -translate-y-1/2 z-52 lg:w-1/2! max-h-[90vh] overflow-auto") do
          tag.h2(title, class: "glow") +
          tag.hr(class: "border-dotted mt-2") +
          tag.div(capture(&block), class: "overflow-auto") +
          button_tag("Close", data: { action: "click->turbo-modal#hideModal" }, type: "button", class: "btn mt-4")
        end
      end
    end
  end
end

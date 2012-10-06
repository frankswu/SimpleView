module SimpleView
  module UIView
    attr_accessor :name, :top, :left, :bottom, :right, :width, :height, :anchors
    attr_accessor :left_to, :right_to, :top_of, :bottom_of

    def find name
      subviews.each do |subview|
        return subview if subview.name == name
      end
      nil
    end
    alias_method :subview, :find

    def sibling name
      if superview
        superview.find name
      else
        nil
      end
    end

    def closest name
      view = sibling name
      if view.nil? && superview
        view = superview.closest name
      end
      view
    end

    def translate_anchors_into_constraints
      return if superview.nil?

      @anchors ||= [:top, :left]
      translate_horizontal_anchors_into_constraints
      translate_vertical_anchors_into_constraints
    end

    def size= value
      @width = value[0]
      @height = value[1]
    end

    private

    def translate_horizontal_anchors_into_constraints
      anchor_left = @anchors.include?(:left) || @anchors.include?(:all)
      anchor_right = @anchors.include?(:right) || @anchors.include?(:all)

      if (anchor_left && anchor_right) || (anchor_left && !@right.nil?)
        setVisualConstraint "H:|-#{@left.to_i}-[v]-#{@right.to_i}-|"
      elsif anchor_right
        setVisualConstraint "H:[v(#{@width.to_i})]-#{@right.to_i}-|"
      elsif !anchor_left && !anchor_right
        if left_to.nil? && right_to.nil?
          setVisualConstraint "H:[v(#{@width.to_i})]"
          superview.addConstraint NSLayoutConstraint.constraintWithItem self,
            attribute: NSLayoutAttributeCenterX,
            relatedBy: NSLayoutRelationEqual,
            toItem: superview,
            attribute: NSLayoutAttributeCenterX,
            multiplier: 1,
            constant: 0
        else
          setVisualConstraintWith left_to, "H:[v1(#{@width.to_i})]-#{@right.to_i}-[v2]" if left_to
          setVisualConstraintWith right_to, "H:[v2]-#{@left.to_i}-[v1(#{@width.to_i})]" if right_to
        end
      else
        setVisualConstraint "H:|-#{@left.to_i}-[v(#{@width.to_i})]"
      end
    end

    def translate_vertical_anchors_into_constraints
      anchor_top = @anchors.include?(:top) || @anchors.include?(:all)
      anchor_bottom = @anchors.include?(:bottom) || @anchors.include?(:all)

      if (anchor_top && anchor_bottom) || (anchor_top && !@bottom.nil?)
        setVisualConstraint "V:|-#{@top.to_i}-[v]-#{@bottom.to_i}-|"
      elsif anchor_bottom
        setVisualConstraint "V:[v(#{@height.to_i})]-#{@bottom.to_i}-|"
      elsif !anchor_top && !anchor_bottom
        if top_of.nil? && bottom_of.nil?
          setVisualConstraint "V:[v(#{@height.to_i})]"
          superview.addConstraint NSLayoutConstraint.constraintWithItem self,
            attribute: NSLayoutAttributeCenterY,
            relatedBy: NSLayoutRelationEqual,
            toItem: superview,
            attribute: NSLayoutAttributeCenterY,
            multiplier: 1,
            constant: 0
        else
          setVisualConstraintWith top_of, "V:[v1(#{@height.to_i})]-#{@bottom.to_i}-[v2]" if top_of
          setVisualConstraintWith bottom_of, "V:[v2]-#{@top.to_i}-[v1(#{@height.to_i})]" if bottom_of
        end
      else
        setVisualConstraint "V:|-#{@top.to_i}-[v(#{@height.to_i})]"
      end
    end

    def setVisualConstraint format
      superview.addConstraints NSLayoutConstraint.constraintsWithVisualFormat(format,
        options: 0,
        metrics: nil,
        views: {'v' => self})
    end

    def setVisualConstraintWith another_view, format
      superview.addConstraints NSLayoutConstraint.constraintsWithVisualFormat(format,
        options: 0,
        metrics: nil,
        views: {'v1' => self, 'v2' => view_instance_of(another_view)})
    end

    def view_instance_of view
      view.is_a?(String) ? closest(view) : view
    end
  end
end

UIView.send(:include, SimpleView::UIView)
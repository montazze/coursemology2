module Course::LessonPlanConcern
  extend ActiveSupport::Concern

  # Groups lesson plan items by their milestone.
  #
  # This combines the lesson plan milestones with the items, grouping them by milestone.
  #
  # There may be a special key, +nil+ for items which do not come under a milestone.
  #
  # @return [Hash{Course::LessonPlanMilestone,nil=>Array<Course::LessonPlanItem>}]
  #   The items grouped by key, with a nil key indicating items not belonging to any milestone.
  def grouped_lesson_plan_items_with_milestones
    milestones = lesson_plan_milestones.order(start_time: :asc).to_a
    items = lesson_plan_items.order(start_time: :asc).includes(:actable).to_a

    group_lesson_plan_items_with_milestones(milestones, items)
  end

  private

  # Groups the given items against the given set of milestones.
  #
  # @param [Array<Course::LessonPlanMilestone] milestones The milestones in the lesson plan.
  #   These milestones must be sorted in chronological order.
  # @param [Array<Course::LessonPlanItem] items The items in the lesson plan.
  #   These items must be sorted in chronological order.
  # @return [Hash{Course::LessonPlanMilestone,nil=>Array<Course::LessonPlanItem>}]
  def group_lesson_plan_items_with_milestones(milestones, items)
    current_milestone = nil
    milestones_hash = {}
    milestones.each { |m| milestones_hash[m] = [] }

    items.each_with_object(milestones_hash) do |item, result|
      current_milestone = milestones.shift if !milestones.empty? &&
                                              milestones.first.start_time < item.start_time

      result[current_milestone] ||= []
      result[current_milestone] << item
    end
  end
end
